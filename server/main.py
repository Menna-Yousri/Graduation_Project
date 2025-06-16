from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import JSONResponse
import os, random, glob, cv2, numpy as np
from datetime import datetime, timezone
from disease_detection.app import infer_abdominal_lumpy, infer_abdominal_mastitis, generate_disease_report
from camera_simulation import simulate_camera_capture, encode_array_to_base64
from database import engine, get_db, Base
from sqlalchemy.orm import Session
from schemas import UserCreate, UserLogin, UserResponse, CowDetailResponse, CowSummary,CowReportDetailResponse, CowReportMetaResponse, NotificationResponse, HomePageStats, ChatResponse, ChatRequest
from fastapi.middleware.cors import CORSMiddleware
from passlib.context import CryptContext
from models import User, Cow, CowReport
import asyncio
from typing import List
import json
from chatbot.app import get_smart_answer_vet, get_smart_answer_farmer
from feed_feature import run_crew_process
from typing import Dict, Any
from schemas import (
    CowProfileRequest,
    IdealFeedFormulationResponse,
    FeedComparisonReportResponse,
    BestFeedRecommendationOutputResponse
)
Base.metadata.create_all(bind=engine)


app = FastAPI()

# Setup CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

latest_frame = {}


async def camera_loop():
    while True:
        db: Session = None
        try:
            rgb, depth, timestamp, image_path = simulate_camera_capture("./disease_detection/images")
            cow_id = f"{random.randint(1, 10):02}"

            latest_frame["rgb_image"] = encode_array_to_base64(rgb)
            latest_frame["depth_map"] = encode_array_to_base64(depth, is_depth=True)
            latest_frame["timestamp"] = timestamp
            latest_frame["cow_id"] = cow_id

            lumpy_result, lumpy_description = infer_abdominal_lumpy(image_path)
            mastitis_result, mastitis_description = infer_abdominal_mastitis(image_path)

            lumpy_detected = (
                lumpy_result.get("Predicted Label") == "Lumpy Skin"
                and float(lumpy_result.get("Confidence", "0").replace("%", "")) >= 50.0
            )
            mastitis_detected = (
                mastitis_result.get("Predicted Label") == "Infected"
                and float(mastitis_result.get("Confidence", "0").replace("%", "")) >= 50.0
            )

            db = next(get_db())

            if lumpy_detected or mastitis_detected:
                disease = "Lumpy Skin Disease" if lumpy_detected else "Mastitis"
                description = lumpy_description if lumpy_detected else mastitis_description
                result = lumpy_result if lumpy_detected else mastitis_result

                report = generate_disease_report(description, result, cow_id, timestamp, disease)
                dt = datetime.fromisoformat(timestamp)

                # Get the next report ID for this cow
                existing_reports = db.query(CowReport).filter(CowReport.cow_id == int(cow_id)).count()
                next_per_cow_report_id = existing_reports + 1

                cow_report = CowReport(cow_id=int(cow_id) , per_cow_report_id=next_per_cow_report_id ,
                    report_json=report , date=dt.date() , time=dt.time())

                db.add(cow_report)


                existing = db.query(Cow).filter(Cow.id == int(cow_id)).first()
                if existing:
                    existing.date = dt.date()
                    existing.time = dt.time()
                    existing.is_sick = True
                else:
                    cow = Cow(id=int(cow_id), date=dt.date(), time=dt.time(), is_sick=True)
                    db.add(cow)

            else:
                existing = db.query(Cow).filter(Cow.id == int(cow_id)).first()
                if existing and existing.is_sick:
                    existing.date = None
                    existing.time = None
                    existing.is_sick = False
                    print(f"[INFO] Cow {cow_id} is now healthy.")
                elif not existing:
                    cow = Cow(id=int(cow_id), date=None, time=None, is_sick=False)
                    db.add(cow)

            db.commit()
            print(f"[INFO] Captured at {timestamp} (Cow ID: {cow_id})")

        except Exception as e:
            print(f"[ERROR] {str(e)}")
            if db:
                db.rollback()
        finally:
            if db:
                db.close()

        await asyncio.sleep(100)

# 🟢 Start camera loop on startup
@app.on_event("startup")
async def startup_event():
    asyncio.create_task(camera_loop())

# 🟢 Initialize 10 cows
@app.post("/init_cows")
def initialize_cows(db: Session = Depends(get_db)):
    db.query(Cow).delete()
    db.commit()

    for i in range(1, 11):
        cow = Cow(id=i, is_sick=False, date=None, time=None)
        db.add(cow)

    db.commit()
    return {"message": "10 cows initialized successfully."}

# 🟢 Latest camera snapshot
@app.get("/camera/latest")
def get_latest_capture():
    if not latest_frame:
        return JSONResponse(status_code=404, content={"error": "No capture yet"})
    return JSONResponse(content=latest_frame)

# 🟢 Sick cow notifications
@app.get("/notification", response_model=List[NotificationResponse])
def get_notifications(db: Session = Depends(get_db)):
    sick_cows = db.query(Cow).filter(Cow.is_sick == True)\
        .order_by(Cow.date.desc(), Cow.time.desc()).all()

    notifications = []
    for cow in sick_cows:
        timestamp = datetime.combine(cow.date, cow.time)
        human_readable = NotificationResponse.get_human_readable_duration(timestamp)
        notifications.append(NotificationResponse(cow_id=str(cow.id), since=human_readable))

    return notifications

# 🟢 All cows
@app.get("/cows", response_model=List[CowSummary])
def get_all_cows(db: Session = Depends(get_db)):
    cows = db.query(Cow).all()
    return [{"cow_id": str(c.id), "is_sick": c.is_sick} for c in cows]

# 🟢 Get list of reports for a cow
@app.get("/cows/{cow_id}/reports", response_model=List[CowReportMetaResponse])
def get_cow_reports(cow_id: int, db: Session = Depends(get_db)):
    reports = db.query(CowReport).filter(CowReport.cow_id == cow_id)\
        .order_by(CowReport.date.desc(), CowReport.time.desc()).all()

    if not reports:
        raise HTTPException(status_code=404, detail="No reports found for this cow")

    return [{"report_id": r.id, "date": r.date, "time": r.time} for r in reports]

# 🟢 Get details of a specific report
@app.get("/cows/{cow_id}/reports/{report_id}", response_model=CowReportDetailResponse)
def get_specific_cow_report(cow_id: int, report_id: int, db: Session = Depends(get_db)):
    report = db.query(CowReport).filter(
        CowReport.cow_id == cow_id,
        CowReport.per_cow_report_id == report_id
    ).first()

    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    return CowReportDetailResponse(
        report_id=report.per_cow_report_id,  # Return the cow-specific report ID
        cow_id=report.cow_id,
        date=report.date,
        time=report.time,
        disease_name=report.report_json.get("disease_name"),
        description=report.report_json.get("description"),
        causes=report.report_json.get("causes"),
        symptoms=report.report_json.get("symptoms"),
        is_contagious=report.report_json.get("is_contagious"),
        severity=report.report_json.get("severity"),
        farmer_advice=report.report_json.get("farmer_advice"),
        needs_vet_attention=report.report_json.get("needs_vet_attention")
    )


# 🟢 Homepage stats
@app.get("/homepage", response_model=HomePageStats)
def get_homepage_stats(db: Session = Depends(get_db)):
    total = db.query(Cow).count()
    sick = db.query(Cow).filter(Cow.is_sick == True).count()

    recent_sick_cows = db.query(Cow)\
        .filter(Cow.is_sick == True)\
        .order_by(Cow.date.desc(), Cow.time.desc())\
        .limit(10).all()

    notifications = []
    for cow in recent_sick_cows:
        timestamp = datetime.combine(cow.date, cow.time)
        human_readable = NotificationResponse.get_human_readable_duration(timestamp)
        notifications.append(NotificationResponse(cow_id=str(cow.id), since=human_readable))

    return HomePageStats(
        total_cows=total,
        sick_cows=sick,
        recent_notifications=notifications
    )


# Password hasher
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

# Sign up endpoint
@app.post("/signup")
def signup(user: UserCreate, db: Session = Depends(get_db)):
    if user.password != user.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=409, detail="Email already registered")

    new_user = User(
        name=user.name,
        email=user.email,
        password=hash_password(user.password),
        is_manager=user.is_manager
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

# Login endpoint
@app.post("/login", response_model=UserResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    return UserResponse(is_manager=db_user.is_manager)

@app.post("/chat/farmer", response_model=ChatResponse)
def chat_farmer(request: ChatRequest):
    try:
        result = json.loads(get_smart_answer_farmer(request.question))
        return ChatResponse(answer=result.get("answer", ""), type=result.get("type", "unknown"))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/chat/vet", response_model=ChatResponse)
def chat_vet(request: ChatRequest):
    try:
        result = json.loads(get_smart_answer_vet(request.question))
        return ChatResponse(answer=result.get("answer", ""), type=result.get("type", "unknown"))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- In-memory Cache for CrewAI Results ---
# Stores results of run_crew_process keyed by a hash of the CowProfileRequest.
# Note: This cache is cleared every time the FastAPI application restarts.
_cached_results: Dict[str, Dict[str, Any]] = {}

def _get_cow_profile_hash(cow_profile: CowProfileRequest) -> str:
    """
    Generates a consistent hash string for a CowProfileRequest to be used as a cache key.
    Converts the Pydantic model to a dictionary, then to a sorted JSON string.
    """
    # Convert to dictionary using by_alias=True to match input keys
    profile_dict = cow_profile.dict(by_alias=True)
    # Sort keys to ensure consistent JSON string for hashing
    sorted_profile_json = json.dumps(profile_dict, sort_keys=True)
    return sorted_profile_json

# --- FastAPI Endpoints ---

@app.post(
    "/feed-recommendation",
    response_model=IdealFeedFormulationResponse,
    summary="Get Ideal Feed Formulation",
    description="Analyzes cow profile and returns an ideal feed formulation. Results are cached."
)
async def get_feed_recommendation(cow_profile: CowProfileRequest):
    """
    Endpoint to get the ideal feed formulation for a cow.
    Requires a CowProfileRequest in the body.
    The CrewAI process will run once per unique cow profile, and results will be cached.
    """
    profile_hash = _get_cow_profile_hash(cow_profile)

    if profile_hash not in _cached_results:
        # If not in cache, run the expensive CrewAI process
        print(f"Cache miss for profile: {profile_hash[:50]}... Running CrewAI process.")
        results = await run_crew_process(cow_profile)
        _cached_results[profile_hash] = results
    else:
        # If in cache, retrieve cached results
        print(f"Cache hit for profile: {profile_hash[:50]}... Serving from cache.")
        results = _cached_results[profile_hash]

    return results["feed_recommendation"]

@app.post(
    "/feed-balance-check",
    response_model=FeedComparisonReportResponse,
    summary="Get Feed Balance Check Report",
    description="Compares current feed with ideal formulation and provides a detailed balance report. Results are cached."
)
async def get_feed_balance_check(cow_profile: CowProfileRequest):
    """
    Endpoint to get a report comparing the current feed with the ideal formulation.
    Requires a CowProfileRequest in the body.
    The CrewAI process will run once per unique cow profile, and results will be cached.
    """
    profile_hash = _get_cow_profile_hash(cow_profile)

    if profile_hash not in _cached_results:
        # If not in cache, run the expensive CrewAI process
        print(f"Cache miss for profile: {profile_hash[:50]}... Running CrewAI process.")
        results = await run_crew_process(cow_profile)
        _cached_results[profile_hash] = results
    else:
        # If in cache, retrieve cached results
        print(f"Cache hit for profile: {profile_hash[:50]}... Serving from cache.")
        results = _cached_results[profile_hash]

    return results["feed_balance_check"]

@app.post(
    "/best-feed-recommendation",
    response_model=BestFeedRecommendationOutputResponse,
    summary="Get Best Feed Product Recommendation",
    description="Evaluates available feed products and recommends the best option based on value and suitability. Results are cached."
)
async def get_best_feed_recommendation(cow_profile: CowProfileRequest):
    """
    Endpoint to get the best recommended feed product.
    Requires a CowProfileRequest in the body.
    The CrewAI process will run once per unique cow profile, and results will be cached.
    """
    profile_hash = _get_cow_profile_hash(cow_profile)

    if profile_hash not in _cached_results:
        # If not in cache, run the expensive CrewAI process
        print(f"Cache miss for profile: {profile_hash[:50]}... Running CrewAI process.")
        results = await run_crew_process(cow_profile)
        _cached_results[profile_hash] = results
    else:
        # If in cache, retrieve cached results
        print(f"Cache hit for profile: {profile_hash[:50]}... Serving from cache.")
        results = _cached_results[profile_hash]

    return results["best_feed_recommendation"]