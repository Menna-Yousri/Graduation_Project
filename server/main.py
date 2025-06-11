from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import JSONResponse
import os, random, glob, cv2, numpy as np
from datetime import datetime, timezone
from disease_detection.app import infer_abdominal_lumpy, infer_abdominal_mastitis, generate_disease_report
from camera_simulation import simulate_camera_capture, encode_array_to_base64
from database import engine, get_db, Base
from sqlalchemy.orm import Session
from schemas import UserCreate, UserLogin, UserResponse, CowDetailResponse, CowSummary, CowReportResponse, NotificationResponse, HomePageStats
from fastapi.middleware.cors import CORSMiddleware
from passlib.context import CryptContext
from models import User, Cow
import asyncio
from typing import List
import json


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
        try:
            rgb, depth, timestamp, image_path = simulate_camera_capture("./disease_detection/images")
            cow_id = f"{random.randint(1, 10):02}"

            latest_frame["rgb_image"] = encode_array_to_base64(rgb)
            latest_frame["depth_map"] = encode_array_to_base64(depth, is_depth=True)
            latest_frame["timestamp"] = timestamp
            latest_frame["cow_id"] = cow_id

            lumpy_result, lumpy_description = infer_abdominal_lumpy(image_path)
            mastitis_result, mastitis_description = infer_abdominal_mastitis(image_path)

            lumpy_detected = (lumpy_result.get("Predicted Label") == "Lumpy Skin" and float(
                lumpy_result.get("Confidence", "0").replace('%', '')) >= 50.0)

            mastitis_detected = (mastitis_result.get("Predicted Label") == "Infected" and float(
                mastitis_result.get("Confidence", "0").replace('%', '')) >= 50.0)

            if lumpy_detected or mastitis_detected:
                disease = "Lumpy Skin Disease" if lumpy_detected else "Mastitis"
                description = lumpy_description if lumpy_detected else mastitis_description
                result = lumpy_result if lumpy_detected else mastitis_result

                report = generate_disease_report(description, result, cow_id, timestamp, disease)


                dt = datetime.fromisoformat(timestamp)
                cow = Cow(
                    id=int(cow_id),
                    report=report,
                    date=dt.date(),
                    time=dt.time(),
                    is_sick=True
                )
                db: Session = next(get_db())
                existing = db.query(Cow).filter(Cow.id == int(cow_id)).first()
                if existing:
                    existing.report = report
                    existing.date = dt.date()
                    existing.time = dt.time()
                    existing.is_sick = True
                else:
                    db.add(cow)

                db.commit()

            print(f"[INFO] Captured at {timestamp} (Cow ID: {cow_id})")

        except Exception as e:
            print(f"[ERROR] {str(e)}")
        await asyncio.sleep(100)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(camera_loop())

@app.post("/init_cows")
def initialize_cows(db: Session = Depends(get_db)):
    inserted = 0
    for i in range(1, 11):
        existing = db.query(Cow).filter(Cow.id == i).first()
        if not existing:
            cow = Cow(id=i, is_sick=False, report=None, date=None, time=None)
            db.add(cow)
            inserted += 1
    db.commit()
    return {"message": f"{inserted} cows initialized."}

@app.get("/camera/latest")
def get_latest_capture():
    if not latest_frame:
        return JSONResponse(status_code=404, content={"error": "No capture yet"})
    return JSONResponse(content=latest_frame)

@app.get("/notification", response_model=List[NotificationResponse])
def get_notifications(db: Session = Depends(get_db)):
    sick_cows = db.query(Cow).filter(Cow.is_sick == True) \
        .order_by(Cow.date.desc(), Cow.time.desc()).all()

    notifications = []
    for cow in sick_cows:
        timestamp = datetime.combine(cow.date, cow.time)
        human_readable = NotificationResponse.get_human_readable_duration(timestamp)
        notifications.append(NotificationResponse(cow_id=str(cow.id), since=human_readable))

    return notifications



@app.get("/cows", response_model=List[CowSummary])
def get_all_cows(db: Session = Depends(get_db)):
    cows = db.query(Cow).all()
    return [{"cow_id": str(c.id), "is_sick": c.is_sick} for c in cows]

@app.get("/cows/{cow_id}", response_model=CowDetailResponse)
def get_cow_report(cow_id: int, db: Session = Depends(get_db)):
    cow = db.query(Cow).filter(Cow.id == cow_id).first()
    if not cow:
        raise HTTPException(status_code=404, detail="Cow not found")

    report = cow.report if cow.is_sick and cow.report else None
    return CowDetailResponse(
        cow_id=str(cow_id),
        is_sick=cow.is_sick,
        report=report
    )


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