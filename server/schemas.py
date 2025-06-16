from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional, Literal, Dict, Any
from datetime import date, time, datetime
import math

# Base shared user attributes
class UserBase(BaseModel):
    email: EmailStr
    is_manager: bool = False

# Create account
class UserCreate(UserBase):
    name: str = Field(..., min_length=2)
    password: str = Field(..., min_length=6)
    confirm_password: str = Field(..., min_length=6)

# Login request
class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    is_manager: bool

class NotificationResponse(BaseModel):
    cow_id: str
    since: str

    @staticmethod
    def get_human_readable_duration(since_datetime: datetime) -> str:
        now = datetime.now()
        delta: timedelta = now - since_datetime

        seconds = delta.total_seconds()
        minutes = seconds / 60
        hours = minutes / 60
        days = delta.days
        weeks = days // 7
        months = days // 30
        years = days // 365

        if years >= 1:
            return f"{years} year{'s' if years > 1 else ''} ago"
        elif months >= 1:
            return f"{months} month{'s' if months > 1 else ''} ago"
        elif weeks >= 1:
            return f"{weeks} week{'s' if weeks > 1 else ''} ago"
        elif days >= 1:
            return f"{days} day{'s' if days > 1 else ''} ago"
        elif hours >= 1:
            return f"{int(hours)} hour{'s' if int(hours) > 1 else ''} ago"
        elif minutes >= 1:
            return f"{int(minutes)} minute{'s' if int(minutes) > 1 else ''} ago"
        else:
            return "just now"

class CowSummary(BaseModel):
    cow_id: str
    is_sick: bool

class CowReportMetaResponse(BaseModel):
    report_id: int
    date: date
    time: time

class CowReportDetailResponse(BaseModel):
    report_id: int
    cow_id: int
    date: date
    time: time
    disease_name: str
    description: str
    causes: List[str]
    symptoms: List[str]
    is_contagious: str
    severity: str
    farmer_advice: str
    needs_vet_attention: str


class CowDetailResponse(BaseModel):
    cow_id: str
    is_sick: bool
    report: Optional[CowReportDetailResponse]

class HomePageStats(BaseModel):
    total_cows: int
    sick_cows: int
    recent_notifications: List[NotificationResponse]


class ChatRequest(BaseModel):
    question: str

class ChatResponse(BaseModel):
    answer: str
    type: str


# --- Pydantic Models for Data Structure (from your original feed_feature.py) ---
# These models define the structure of the data processed by the agents.

class FeedComponent(BaseModel):
    name: str
    amount_kg: float
    protein_percent: Optional[float] = None
    fiber_percent: Optional[float] = None
    energy_mcal: Optional[float] = None
    notes: str
    sources: List[str]

class WaterComponent(BaseModel):
    liters: float
    notes: str
    sources: List[str]

class IdealFeedFormulation(BaseModel):
    roughage: FeedComponent
    concentrate: FeedComponent
    supplements: List[FeedComponent]
    water: WaterComponent
    notes: str

class FeedComparisonReport(BaseModel):
    balanced: bool
    missing_nutrients: List[str]
    surplus_nutrients: List[str]
    comparison_notes: str
    improved_feed_recommendation: IdealFeedFormulation

class SuggestedSearchQueries(BaseModel):
    queries: List[str] = Field(
        ..., min_items=5, max_items=10,
        title="الكلمات المفتاحية المقترحة للبحث عن أعلاف الأبقار"
    )

class FeedProductResult(BaseModel):
    product_name: str
    protein_percent: float
    price_per_kg: float
    key_ingredients: List[str]
    matches_ideal_formula: bool
    match_reason: str
    supplier_rating: Optional[float] = Field(None, ge=0, le=5)
    url: str

class BestFeedRecommendationOutput(BaseModel):
    top_3_products: List[FeedProductResult]
    best_product: FeedProductResult
    recommendation_reason: str

# --- Pydantic Models for FastAPI Request/Response ---
# These models are used for the API's input and output, extending the core models
# to include the `generated_date` and `generated_time` fields.

class CowProfileRequest(BaseModel):
    """
    Input model for the cow's profile, mirroring the 'inputs' dictionary
    used in the CrewAI kickoff method.
    """
    type_: Literal["dairy", "beef"] = Field(..., alias="type")
    age: int = Field(..., ge=0, le=20)
    weight: int = Field(..., ge=200, le=1000)
    goal: Literal["milk", "meat"]
    milk_yield: float = Field(0, ge=0)
    pregnant: bool = False
    breed: Optional[str] = None
    feed_used: Optional[List[str]] = Field(None, alias="current_feed") # Matches the 'feed_used' key in kickoff
    activity_level: Optional[Literal["low", "medium", "high"]] = "low"
    health_status: Optional[Literal["good", "fair", "poor"]] = "good"
    season: Optional[Literal["spring", "summer", "autumn", "winter"]] = "winter"
    animal_type: str = "البقرة"
    production_goal: str = "زيادة إنتاج اللحوم"
    country_name: str = "Egypt"
    product_name: str = "livestock nutrition"
    no_keywords: int = 10
    language: str = "Arabic"
    score_th: float = 0.7

    class Config:
        populate_by_name = True # Allows Pydantic to use the 'alias' for field names


class IdealFeedFormulationResponse(IdealFeedFormulation):
    """Response model for the ideal feed formulation, including date and time."""
    generated_date: str
    generated_time: str

class FeedComparisonReportResponse(FeedComparisonReport):
    """Response model for the feed balance check report, including date and time."""
    generated_date: str
    generated_time: str

class BestFeedRecommendationOutputResponse(BestFeedRecommendationOutput):
    """Response model for the best feed recommendation, including date and time."""
    generated_date: str
    generated_time: str