from database import Base
from sqlalchemy import Column, Integer, String, JSON, Date, Time, Boolean


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
