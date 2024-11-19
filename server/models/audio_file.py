# models/audio_file.py
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from models.base import Base

class AudioFile(Base):
    __tablename__ = "audio_files"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    blob_name = Column(String, index=True)
    file_url = Column(String, nullable=False)
    uploaded_at = Column(DateTime, default=datetime.utcnow)

    # Quan hệ với User
    owner = relationship("User", back_populates="audio_files")
    
    # Quan hệ với Transcription (một-một)
    transcription = relationship("Transcription", back_populates="audio_file", uselist=False, cascade="all, delete-orphan")
