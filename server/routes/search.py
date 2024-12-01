import uuid 
from fastapi import APIRouter, HTTPException, Depends, Request
from sqlalchemy.orm import Session
from models.user import User
from models.audio_file import AudioFile
from models.transcription import Transcription
from middleware.auth_middleware import auth_middleware
from database import get_db
import logging
from typing import List
from sqlalchemy import func
from unidecode import unidecode

router = APIRouter()

from sqlalchemy import func

@router.get("/search", response_model=List[dict]) 
def search_audio_files(query: str, db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    try:
        user_id = user_dict['uid']
        # Chuyển đổi query sang không dấu và lowercase
        normalized_query = unidecode(query.lower())

        search_results = (
            db.query(AudioFile, Transcription)
            .join(Transcription, AudioFile.id == Transcription.audio_file_id, isouter=True)
            .filter(
                AudioFile.user_id == user_id,
                (
                    # Tìm kiếm không dấu và không phân biệt hoa thường 
                    func.lower(func.unaccent(Transcription.content)).like(f"%{normalized_query}%") |
                    func.lower(func.unaccent(AudioFile.title)).like(f"%{normalized_query}%")
                )
            )
            .order_by(AudioFile.uploaded_at.desc())
            .all()
        )

        return [
            {
                "audio": {
                    "id": audio.id,
                    "title": audio.title,
                    "file_url": audio.file_url,
                    "uploaded_at": audio.uploaded_at.isoformat(),
                    "duration": audio.duration,
                    "blob_name": audio.blob_name,
                    "transcription_id": audio.transcription.id if audio.transcription else None
                },
                "transcription": {
                    "id": transcription.id if transcription else None,
                    "audio_file_id": transcription.audio_file_id if transcription else None,
                    "content": transcription.content if transcription else None,
                    "created_at": transcription.created_at.isoformat() if transcription else None,
                    "is_processing": transcription.is_processing if transcription else None,
                    "is_error": transcription.is_error if transcription else None,
                }
            } 
            for audio, transcription in search_results
        ]
    except Exception as e:
        logging.error(f"Search error: {e}")
        raise HTTPException(status_code=500, detail=str(e))