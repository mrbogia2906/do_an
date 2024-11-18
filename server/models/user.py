# models/user.py
from sqlalchemy import Column, String
from sqlalchemy.orm import relationship
from models.base import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    name = Column(String, nullable=False)

    # Quan hệ với AudioFile
    audio_files = relationship("AudioFile", back_populates="owner", cascade="all, delete-orphan")
