# models/transcription.py
from sqlalchemy import Column, String, ForeignKey, DateTime, Text, Boolean
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from models.base import Base
from datetime import datetime

class Transcription(Base):
    __tablename__ = "transcriptions"

    id = Column(String, primary_key=True, index=True)
    audio_file_id = Column(String, ForeignKey("audio_files.id"), nullable=False, unique=True)
    content = Column(Text, nullable=True)
    summary = Column(Text, nullable=True)
    is_processing = Column(Boolean, default=True)
    is_error = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    word_timings = Column(JSONB, nullable=True)

    # Quan hệ với AudioFile, xác định mối quan hệ một-một
    audio_file = relationship(
        "AudioFile",
        back_populates="transcription",
        uselist=False  # Một-một
    )
    
    todos = relationship("Todo", back_populates="transcription", cascade="all, delete-orphan")

