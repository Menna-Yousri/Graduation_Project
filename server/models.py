from database import Base
from sqlalchemy import Column, Integer, String, JSON, Date, Time, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    is_manager = Column(Boolean, default=False)


class Cow(Base):
    __tablename__ = "cows"

    id = Column(Integer, primary_key=True, index=True)
    report = Column(JSON, nullable=True)
    date = Column(Date, nullable=True)
    time = Column(Time, nullable=True)
    is_sick = Column(Boolean, default=False)

class CowReport(Base):
    __tablename__ = "cow_reports"

    id = Column(Integer, primary_key=True, index=True)  # Global unique
    cow_id = Column(Integer, ForeignKey("cows.id"))
    per_cow_report_id = Column(Integer)  # Unique per cow
    report_json = Column(JSON, nullable=False)
    date = Column(Date, nullable=False)
    time = Column(Time, nullable=False)

    cow = relationship("Cow", backref="reports")

    __table_args__ = (
        # Ensure each cow has unique per_cow_report_id
        UniqueConstraint("cow_id", "per_cow_report_id", name="unique_cow_report"),
    )

