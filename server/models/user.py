# models/user.py
from sqlalchemy import Column, String, Integer, Boolean
from sqlalchemy.orm import relationship
from models.base import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    name = Column(String, nullable=False)
    
    is_premium = Column(Boolean, default=False)
    max_audio_files = Column(Integer, default=10)  
    max_total_audio_time = Column(Integer, default=18000)
    total_audio_time = Column(Integer, default=0)

    audio_files = relationship("AudioFile", back_populates="owner", cascade="all, delete-orphan")
    subscriptions = relationship("Subscription", back_populates="user", cascade="all, delete-orphan")