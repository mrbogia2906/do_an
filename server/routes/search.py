import uuid 
from fastapi import APIRouter, HTTPException, Depends, Request
from sqlalchemy.orm import Session
from models.user import User
from models.audio_file import AudioFile
from models.transcription import Transcription
from models.todo import Todo
from middleware.auth_middleware import auth_middleware
from database import get_db
import logging
from typing import List
from sqlalchemy import func
from unidecode import unidecode
from thefuzz import fuzz

router = APIRouter()

from sqlalchemy import func

@router.get("/search", response_model=List[dict]) 
def search_audio_files(query: str, db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    try:
        user_id = user_dict['uid']
        # Chuẩn hóa truy vấn: loại bỏ dấu và chuyển thành chữ thường
        normalized_query = unidecode(query.lower())
        
        # Sử dụng unaccent trong truy vấn SQL để loại bỏ dấu
        search_pattern = f"%{query.lower()}%"
        normalized_search_pattern = f"%{normalized_query}%"

        # Tìm kiếm trong tiêu đề và nội dung transcription
        all_results = (
            db.query(AudioFile, Transcription)
            .join(Transcription, AudioFile.id == Transcription.audio_file_id, isouter=True)
            .filter(AudioFile.user_id == user_id)
            .filter(
                func.unaccent(func.lower(AudioFile.title)).ilike(normalized_search_pattern) |
                func.unaccent(func.lower(Transcription.content)).ilike(normalized_search_pattern) |
                AudioFile.title.ilike(search_pattern) |
                Transcription.content.ilike(search_pattern)
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
                    "transcription_id": transcription.id if transcription else None
                },
                "transcription": {
                    "id": transcription.id if transcription else None,
                    "audio_file_id": transcription.audio_file_id if transcription else None,
                    "content": transcription.content if transcription else None,
                    "summary": transcription.summary if transcription else None,
                    "created_at": transcription.created_at.isoformat() if transcription else None,
                    "is_processing": transcription.is_processing if transcription else None,
                    "is_error": transcription.is_error if transcription else None,
                },
            } 
            for audio, transcription in all_results
        ]
    except Exception as e:
        logging.error(f"Search error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
