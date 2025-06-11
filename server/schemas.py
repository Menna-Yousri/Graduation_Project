from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, List
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

class CowReportResponse(BaseModel):
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
    report: Optional[CowReportResponse]

class HomePageStats(BaseModel):
    total_cows: int
    sick_cows: int
    recent_notifications: List[NotificationResponse]


