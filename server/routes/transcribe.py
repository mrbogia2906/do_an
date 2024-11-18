# routes/transcribe.py
import os
import asyncio
import aiofiles
from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends, logger
from fastapi.responses import JSONResponse
from background import UPLOAD_DIR, queue, process_queue
from middleware.auth_middleware import auth_middleware
from sqlalchemy.orm import Session
from models.audio_file import AudioFile
from models.transcription import Transcription
from database import get_db
from uuid import uuid4
from datetime import datetime, timedelta
from typing import List
from background import upload_to_gcs
import logging
from google.cloud import storage


logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/upload-audio", status_code=201)
async def upload_audio(
    audio: UploadFile = File(...),
    title: str = Form(...),
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        
        # Tạo ID cho AudioFile và Transcription
        audio_id = str(uuid4())
        transcription_id = str(uuid4())
        filename = f"{audio_id}_{audio.filename}"
        file_location = os.path.join(UPLOAD_DIR, filename)

        # Lưu tệp âm thanh vào thư mục uploads
        async with aiofiles.open(file_location, "wb") as buffer:
            while True:
                chunk = await audio.read(1024 * 1024)  # Đọc 1MB tại một thời điểm
                if not chunk:
                    break
                await buffer.write(chunk)
        
        logger.info(f"Audio file saved at {file_location}")  # Debugging

        # Upload audio lên Google Cloud Storage và lấy Signed URL
        file_url = await upload_to_gcs(file_location, filename)

        # Tạo bản ghi AudioFile trong DB
        audio_file = AudioFile(
            id=audio_id,
            user_id=user_id,
            title=title,
            blob_name=filename,
            file_url=file_url,
            uploaded_at=datetime.utcnow(),
        )
        db.add(audio_file)
        db.commit()
        db.refresh(audio_file)

        # Tạo bản ghi Transcription
        transcription = Transcription(
            id=transcription_id,
            audio_file_id=audio_file.id,
            is_processing=True
        )
        db.add(transcription)
        db.commit()
        db.refresh(transcription)

        # Enqueue yêu cầu vào hàng đợi
        future = asyncio.get_event_loop().create_future()
        await queue.put((file_location, transcription.id, future))

        logger.info(f"Enqueued transcription task for {file_location}")  # Debugging

        # Trả về response với thông tin AudioFile và Transcription
        return JSONResponse(
            status_code=201,
            content={
                "id": audio_file.id,
                "title": audio_file.title,
                "file_url": audio_file.file_url,  # Đây là Signed URL
                "uploaded_at": audio_file.uploaded_at.isoformat(),
                "transcription_id": transcription.id,
                "is_processing": transcription.is_processing
            },
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        logger.error("Error during audio upload:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/audio-files", response_model=List[dict])
def get_audio_files(db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    try:
        user_id = user_dict['uid']
        audio_files = db.query(AudioFile).filter(AudioFile.user_id == user_id).all()
        return JSONResponse(
            status_code=200,
            content=[
                {
                    "id": audio.id,
                    "title": audio.title,
                    "file_url": audio.file_url,
                    "uploaded_at": audio.uploaded_at.isoformat(),
                    "transcription_id": audio.transcription.id if audio.transcription else None,
                    "is_processing": audio.transcription.is_processing if audio.transcription else False
                }
                for audio in audio_files
            ],
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        logger.error("Error fetching audio files:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transcriptions/{transcription_id}", response_model=dict)
def get_transcription(
    transcription_id: str,
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        transcription = db.query(Transcription).join(AudioFile).filter(
            Transcription.id == transcription_id,
            AudioFile.user_id == user_id
        ).first()

        if not transcription:
            raise HTTPException(status_code=404, detail="Transcription not found")

        logger.info(f"Returning transcription content: {transcription.content}")

        return JSONResponse(
            status_code=200,
            content={
                "id": transcription.id,
                "audio_file_id": transcription.audio_file_id,
                "content": transcription.content,
                "created_at": transcription.created_at.isoformat(),
                "is_processing": transcription.is_processing,
                "is_error": transcription.is_error
            },
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        logger.error("Error fetching transcription:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/gg-transcribe")
async def transcribe(audio: UploadFile = File(...)):
    try:
        filename = audio.filename
        # Lưu tệp âm thanh tạm thời
        file_location = os.path.join("uploads", filename)
        async with aiofiles.open(file_location, "wb") as buffer:
            while True:
                chunk = await audio.read(1024 * 1024)  # Đọc 1MB tại một thời điểm
                if not chunk:
                    break
                await buffer.write(chunk)
        
        # TODO: Tích hợp với Google Cloud Speech-to-Text nếu cần
        # Đối với ví dụ này, giả sử chúng ta chỉ trả lời một phản hồi mẫu
        # Bạn nên thay thế phần này bằng mã xử lý thực tế như trong các phần trước

        # Xóa tệp sau khi xử lý
        os.remove(file_location)
        
        return {"transcription": "Giả định: Đây là bản chuyển đổi từ Google Cloud Speech-to-Text."}
    except Exception as e:
        logger.error("Error during transcription:", exc_info=True)
        raise HTTPException(status_code=500, detail="Error transcribing audio")

@router.post("/gemini-transcribe")
async def gemini_transcribe(
    audio: UploadFile = File(...),
    id: str = Form(...),
    title: str = Form(...)
):
    try:
        filename = audio.filename
        file_location = os.path.join("uploads", filename)
        
        # Lưu file
        async with aiofiles.open(file_location, 'wb') as out_file:
            while True:
                chunk = await audio.read(1024 * 1024)
                if not chunk:
                    break
                await out_file.write(chunk)

        # Enqueue yêu cầu vào hàng đợi
        future = asyncio.get_event_loop().create_future()
        await queue.put((file_location, id, future))
        
        # Chờ và lấy kết quả
        result = await future
        
        # Trả về response với Content-Type và charset phù hợp
        return JSONResponse(
            content=result,
            media_type="application/json; charset=utf-8",
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )
        
    except Exception as e:
        logger.error("Error during Gemini AI transcription enqueue:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/generate-signed-url/{audio_id}", response_model=dict)
def generate_signed_url(audio_id: str, db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    try:
        user_id = user_dict['uid']
        audio_file = db.query(AudioFile).filter(AudioFile.id == audio_id, AudioFile.user_id == user_id).first()
        if not audio_file:
            raise HTTPException(status_code=404, detail="Audio file not found")

        # Lấy blob_name từ AudioFile
        blob_name = audio_file.blob_name

        # Tạo Signed URL có thời hạn 7 ngày
        client = storage.Client()
        bucket_name = os.getenv("GCS_BUCKET_NAME")
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(blob_name)

        signed_url = blob.generate_signed_url(
            version="v4",
            expiration=timedelta(days=7),
            method="GET"
        )

        return JSONResponse(
            status_code=200,
            content={
                "signed_url": signed_url
            },
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        logger.error("Error generating signed URL:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))