# routes/transcribe.py
import os
import asyncio
import aiofiles
from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends, logger
from fastapi.responses import JSONResponse
from background import UPLOAD_DIR, queue, process_queue, todo_queue
from middleware.auth_middleware import auth_middleware
from sqlalchemy.orm import Session
from models.audio_file import AudioFile
from models.transcription import Transcription
from models.todo import Todo
from models.user import User
from database import get_db
from uuid import uuid4
from datetime import datetime, timedelta
from typing import List
from background import upload_to_gcs
import logging
from google.cloud import storage
from google.cloud import speech
from pydub import AudioSegment
from pydub.utils import which

from pydantic_schemas.audio_file import AudioFileResponse, AudioFileUpdateTitle
from pydantic_schemas.transcription import TranscriptionResponse
from pydantic_schemas.todo import TodoResponse
from tinytag import TinyTag

logger = logging.getLogger(__name__)

router = APIRouter()

AudioSegment.converter = which("ffmpeg")  
AudioSegment.ffprobe = which("ffprobe") 



def get_audio_duration(file_path: str) -> int:
    try:
        tag = TinyTag.get(file_path)
        return int(tag.duration)  # Duration in seconds
    except Exception as e:
        logger.error(f"Error calculating duration for {file_path}: {e}")
        raise HTTPException(status_code=500, detail="Error calculating audio duration")


@router.post("/upload-audio", status_code=201)
async def upload_audio(
    audio: UploadFile = File(...),
    title: str = Form(...),
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        
        # Lấy thông tin người dùng
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Kiểm tra số lượng file hiện tại
        current_file_count = len(user.audio_files)
        if current_file_count >= user.max_audio_files:
            raise HTTPException(status_code=400, detail="You have reached the maximum number of audio files.")
        
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
        
        # Lấy duration của file audio
        duration_seconds = get_audio_duration(file_location)

        # Kiểm tra tổng thời gian audio
        total_audio_time = user.total_audio_time
        if total_audio_time + duration_seconds > user.max_total_audio_time:
            # Xóa file đã lưu nếu vượt quá giới hạn
            os.remove(file_location)
            raise HTTPException(status_code=400, detail="Total audio time exceeds the maximum allowed.")
        
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
            duration=duration_seconds  # Lưu duration tính bằng phút
        )
        db.add(audio_file)
        
        # Cập nhật tổng thời gian audio của người dùng
        user.total_audio_time += duration_seconds

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

        # Trả về response với thông tin AudioFile và Transcription
        return JSONResponse(
            status_code=201,
            content={
                "id": audio_file.id,
                "title": audio_file.title,
                "file_url": audio_file.file_url,  
                "uploaded_at": audio_file.uploaded_at.isoformat(),
                "transcription_id": transcription.id,
                "is_processing": transcription.is_processing,
                "total_audio_time": user.total_audio_time,  # Trả về tổng thời gian audio
                "max_total_audio_time": user.max_total_audio_time
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
        audio_files = (
            db.query(AudioFile)
            .filter(AudioFile.user_id == user_id)
            .order_by(AudioFile.uploaded_at.desc())
            .all()
        )
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

@router.get("/transcriptions/{transcription_id}", response_model=TranscriptionResponse)
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

        return transcription  
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

@router.delete("/transcriptions/{transcription_id}", status_code=200)
def delete_transcription(
    transcription_id: str,
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        # Truy xuất transcription dựa trên transcription_id và user_id
        transcription = db.query(Transcription).join(AudioFile).filter(
            Transcription.id == transcription_id,
            AudioFile.user_id == user_id
        ).first()

        if not transcription:
            raise HTTPException(status_code=404, detail="Transcription not found")

        # Xoá transcription
        db.delete(transcription)
        db.commit()

        logger.info(f"Transcription {transcription_id} deleted by user {user_id}")

        return {"detail": "Transcription deleted successfully"}

    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error("Error deleting transcription:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/audio-files/{audio_id}", status_code=200)
def delete_audio_file(
    audio_id: str,
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        # Truy xuất AudioFile dựa trên audio_id và user_id
        audio_file = db.query(AudioFile).filter(
            AudioFile.id == audio_id,
            AudioFile.user_id == user_id
        ).first()

        if not audio_file:
            raise HTTPException(status_code=404, detail="AudioFile not found")

        # Xoá tệp âm thanh từ thư mục uploads
        file_path = os.path.join(UPLOAD_DIR, audio_file.blob_name)
        if os.path.exists(file_path):
            os.remove(file_path)
            logger.info(f"Deleted audio file from storage: {file_path}")
        else:
            logger.warning(f"Audio file not found in storage: {file_path}")

        # Nếu bạn đang sử dụng Google Cloud Storage, hãy xoá tệp từ GCS
        # Sẽ cần thêm đoạn mã để xoá từ GCS nếu cần thiết
        # Ví dụ:
        from google.cloud import storage
        client = storage.Client()
        bucket = client.bucket(os.getenv("GCS_BUCKET_NAME"))
        blob = bucket.blob(audio_file.blob_name)
        blob.delete()

        # Xoá AudioFile và Transcription liên quan
        db.delete(audio_file)
        db.commit()

        logger.info(f"AudioFile {audio_id} and its Transcription deleted by user {user_id}")

        return {"detail": "AudioFile and Transcription deleted successfully"}

    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error("Error deleting AudioFile and Transcription:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
    
@router.patch("/audio-files/{audio_id}/title", response_model=AudioFileResponse)
def update_audio_file_title(
    audio_id: str,
    audio_update: AudioFileUpdateTitle,
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        # Truy xuất AudioFile dựa trên audio_id và user_id
        audio_file = db.query(AudioFile).filter(
            AudioFile.id == audio_id,
            AudioFile.user_id == user_id
        ).first()

        if not audio_file:
            raise HTTPException(status_code=404, detail="AudioFile not found")

        audio_file.title = audio_update.title
        db.commit()
        db.refresh(audio_file)

        return audio_file
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/generate-todos/{transcription_id}")
async def generate_todos(
    transcription_id: str,
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        # Verify that the transcription exists and belongs to the user
        transcription = db.query(Transcription).join(AudioFile).filter(
            Transcription.id == transcription_id,
            AudioFile.user_id == user_id
        ).first()

        if not transcription:
            raise HTTPException(status_code=404, detail="Transcription not found")

        # Enqueue the transcription_id for to-do generation
        future = asyncio.get_event_loop().create_future()
        await todo_queue.put((transcription_id, future))

        return JSONResponse(
            status_code=200,
            content={"detail": "To-do generation enqueued."}
        )

    except Exception as e:
        logger.error("Error during to-do generation enqueue:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transcriptions/{transcription_id}/todos", response_model=List[TodoResponse])
def get_todos(
    transcription_id: str,
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        transcription = db.query(Transcription).join(AudioFile).filter(
            Transcription.id == transcription_id,
            AudioFile.user_id == user_id
        ).first()

        if not transcription:
            raise HTTPException(status_code=404, detail="Transcription not found")

        todos = db.query(Todo).filter(Todo.transcription_id == transcription_id).all()

        return todos

    except Exception as e:
        logger.error("Error fetching to-dos:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/transcribe-google", status_code=201)
async def transcribe_google(
    audio: UploadFile = File(...),
    title: str = Form(...),
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware)
):
    try:
        user_id = user_dict['uid']
        
        # Generate IDs for AudioFile and Transcription
        audio_id = str(uuid4())
        transcription_id = str(uuid4())
        filename = f"{audio_id}_{audio.filename}"
        file_location = os.path.join(UPLOAD_DIR, filename)

        # Save the uploaded audio file
        async with aiofiles.open(file_location, "wb") as buffer:
            while True:
                chunk = await audio.read(1024 * 1024)  # Read in 1MB chunks
                if not chunk:
                    break
                await buffer.write(chunk)
        
        # Upload audio to Google Cloud Storage
        file_url = await upload_to_gcs(file_location, filename)

        # Create AudioFile record in the database
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

        # Create Transcription record
        transcription = Transcription(
            id=transcription_id,
            audio_file_id=audio_file.id,
            is_processing=True
        )
        db.add(transcription)
        db.commit()
        db.refresh(transcription)

        # Call the transcription function directly
        transcribe_gcs_with_word_time_offsets(file_url, transcription, db)

        # Remove local file after processing
        os.remove(file_location)

        # Return the transcription result
        return JSONResponse(
            status_code=201,
            content={
                "id": transcription.id,
                "audio_file_id": transcription.audio_file_id,
                "content": transcription.content,
                "word_timings": transcription.word_timings,
                "created_at": transcription.created_at.isoformat(),
                "is_processing": transcription.is_processing,
                "is_error": transcription.is_error
            },
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        logger.error("Error during Google transcription:", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


def transcribe_gcs_with_word_time_offsets(audio_uri: str, transcription: Transcription, db: Session):
    client = speech.SpeechClient()

    audio = speech.RecognitionAudio(uri=audio_uri)
    config = speech.RecognitionConfig(
        # Adjust encoding and sample rate as needed
        # Ensure encoding matches your audio file format
        encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
        sample_rate_hertz=16000,  # Adjust based on your audio sample rate
        language_code="en-US",
        enable_word_time_offsets=True,
    )

    operation = client.long_running_recognize(config=config, audio=audio)

    print("Waiting for operation to complete...")
    result = operation.result(timeout=300)  # Adjust timeout as needed

    # Process the results to extract word time offsets
    transcription_text = ""
    word_timings = []
    for res in result.results:
        alternative = res.alternatives[0]
        transcription_text += alternative.transcript
        for word_info in alternative.words:
            word = word_info.word
            start_time = word_info.start_time.total_seconds()
            end_time = word_info.end_time.total_seconds()
            word_timings.append({
                'word': word,
                'start_time': start_time,
                'end_time': end_time,
            })

    # Update the Transcription object
    transcription.content = transcription_text
    transcription.word_timings = word_timings  # Assuming JSON field
    transcription.is_processing = False
    transcription.is_error = False

    db.commit()
