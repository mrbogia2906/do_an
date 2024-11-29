from datetime import timedelta
import os
import asyncio
from dotenv import load_dotenv
from fastapi import UploadFile
import google.generativeai as genai
import aiofiles
import traceback
from google.generativeai.types import HarmCategory, HarmBlockThreshold
from models.transcription import Transcription
from models.audio_file import AudioFile
from models.todo import Todo
from sqlalchemy.orm import Session
from database import SessionLocal
from uuid import uuid4
import mimetypes
from datetime import timedelta
from google.cloud import storage
import mimetypes
import json
from google.cloud import storage
import logging


# Tải các biến môi trường từ .env
load_dotenv()

# Khởi tạo SDK Gemini AI
api_key = os.getenv("API_KEY")
if not api_key:
    raise ValueError("API_KEY không được tìm thấy trong biến môi trường.")

genai.configure(api_key=api_key)

# Tạo thư mục uploads nếu chưa tồn tại
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Tạo hàng đợi
queue = asyncio.Queue()

todo_queue = asyncio.Queue()


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def cors_configuration(bucket_name):
    """Set a bucket's CORS policies configuration."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    bucket.cors = [
        {
            "origin": ["*"],  # Bạn có thể thay đổi "*" thành các domain cụ thể để tăng cường bảo mật
            "responseHeader": ["Content-Type"],
            "method": ["GET", "PUT", "POST", "DELETE"],
            "maxAgeSeconds": 3600
        }
    ]
    bucket.patch()

    print(f"Set CORS policies for bucket {bucket.name} is {bucket.cors}")
    return bucket

# Gọi hàm để thiết lập CORS
cors_configuration("audio_stt_kltn")

async def upload_to_gcs(file_path: str, destination_blob_name: str) -> str:
    try:
        client = storage.Client()
        bucket_name = os.getenv("GCS_BUCKET_NAME")
        if not bucket_name:
            raise ValueError("GCS_BUCKET_NAME không được thiết lập trong biến môi trường.")
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(destination_blob_name)
        
        # Upload từ đường dẫn tệp
        blob.upload_from_filename(file_path, content_type=mimetypes.guess_type(file_path)[0] or 'application/octet-stream')
        
        # Tạo Signed URL có thời hạn 7 ngày
        signed_url = blob.generate_signed_url(expiration=timedelta(days=7), method='GET')
        
        return signed_url
    except Exception as e:
        print("Error uploading to GCS:", e)
        raise e


async def process_queue():
    while True:
        file_location, transcription_id, future = await queue.get()
        try:
            # Khởi tạo session DB
            db: Session = SessionLocal()

            # Lấy bản ghi Transcription
            transcription = db.query(Transcription).filter(Transcription.id == transcription_id).first()
            if not transcription:
                raise Exception(f"Transcription with id {transcription_id} not found.")

            # Kiểm tra MIME type
            mime_type = "audio/mpeg"
            if not mime_type:
                raise ValueError(f"Unknown MIME type for file: {file_location}. Please set the 'mime_type' argument.")

            # Tải tệp âm thanh lên Gemini AI sử dụng File API
            print(f"Uploading file {file_location} using Gemini AI File API.")
            uploaded_file = genai.upload_file(path=file_location, mime_type=mime_type)
            file_name = uploaded_file.name

            # Kiểm tra trạng thái xử lý của tệp
            while True:
                file_metadata = genai.get_file(file_name)
                print(f"File metadata: {file_metadata}")
                print(f"File metadata state: {file_metadata.state}")

                # Xử lý trạng thái
                state = file_metadata.state.name.lower() if hasattr(file_metadata.state, 'name') else str(file_metadata.state).lower()

                if state == "active":
                    print(f"File {file_name} is active.")
                    break
                elif state == "failed":
                    raise Exception("Audio processing failed in Gemini AI.")
                else:
                    print(f"File {file_name} is still processing. Waiting...")
                    await asyncio.sleep(10)  # Chờ 10 giây trước khi kiểm tra lại

            # Tạo mô hình Gemini
            model = genai.GenerativeModel(model_name="gemini-1.5-flash")

            # Tạo prompt phù hợp cho phiên âm
            prompt = "Please provide a transcription of the audio. I need it for learning vocabulary.(Remove unnecessary time markers)"

            # Gửi yêu cầu phiên âm tới Gemini AI
            response = model.generate_content([
                uploaded_file,
                "\n\n",
                prompt
            ],
            safety_settings={
                HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
                HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
            })

            # Kiểm tra finish_reason trước khi truy cập response.text
            if hasattr(response, 'finish_reason') and response.finish_reason == 4:
                raise Exception("Transcription failed: Model detected copyrighted material.")

            # Lấy kết quả phiên âm
            try:
                transcription_content = response.text
            except ValueError as ve:
                print(f"Transcription could not be retrieved: {ve}")
                transcription_content = "Transcription failed: Unable to retrieve transcription text."

            # Cập nhật bản ghi Transcription
            transcription.content = transcription_content
            transcription.is_processing = False
            transcription.is_error = False
            db.commit()

            # Xóa tệp sau khi xử lý
            os.remove(file_location)

            # Đặt kết quả cho yêu cầu
            future.set_result({"id": transcription.id, "title": transcription.audio_file.title, "transcription": transcription.content})

        except Exception as e:
            print("Error during Gemini AI transcription:", e)
            traceback.print_exc()  # In chi tiết stack trace

            # Cập nhật trạng thái lỗi cho Transcription
            db: Session = SessionLocal()
            transcription = db.query(Transcription).filter(Transcription.id == transcription_id).first()
            if transcription:
                transcription.is_processing = False
                transcription.is_error = True
                db.commit()

            future.set_exception(Exception("Error during Gemini AI transcription"))
        finally:
            db.close()
            queue.task_done()

async def process_todo_queue():
    while True:
        transcription_id, future = await todo_queue.get()
        try:
            logger.info(f"Processing to-do generation for transcription_id: {transcription_id}")

            # Initialize DB session
            db: Session = SessionLocal()

            # Get the Transcription record
            transcription = db.query(Transcription).filter(Transcription.id == transcription_id).first()
            if not transcription:
                raise Exception(f"Transcription with id {transcription_id} not found.")

            # Use the transcription content to generate to-dos
            prompt = (
                "Please read the following transcription and extract any actionable items or to-dos mentioned. If the transcription language is what, return the title and description corresponding to that language. "
                "Return only the to-do items as a JSON array in the following format, without any additional text or explanations:\n"
                "[\n  { \"title\": \"Example Task\", \"description\": \"Description of the task.\" },\n  ...\n]\n\n"
                "Transcription:\n\n"
                f"{transcription.content}"
            )

            logger.info(f"Prompt: {prompt}")

            # Use the AI model to generate the to-dos
            model = genai.GenerativeModel(model_name="gemini-1.5-flash")
            response = model.generate_content(prompt)

            # Log the response
            logger.info(f"AI Model Response: '{response.text}'")

            cleaned_response = response.text.strip()
            if cleaned_response.startswith("```json") and cleaned_response.endswith("```"):
                cleaned_response = cleaned_response[len("```json"): -len("```")].strip()

            if not cleaned_response:
                raise ValueError("AI model returned an empty response.")

            # Parse the response to extract to-dos
            try:
                todos_list = json.loads(cleaned_response)
                logger.info(f"Parsed todos: {todos_list}")
            except json.JSONDecodeError as jde:
                logger.error(f"JSON decode error: {jde}")
                logger.error(f"Invalid JSON response: '{cleaned_response}'")
                raise ValueError("AI model returned invalid JSON.")

            # Kiểm tra định dạng của todos_list
            if not isinstance(todos_list, list):
                raise ValueError("AI model response is not a JSON array.")

            # Tạo Todo records
            for todo_data in todos_list:
                if 'title' not in todo_data:
                    raise ValueError("Missing 'title' in to-do item.")
                todo = Todo(
                    transcription_id=transcription.id,
                    title=todo_data['title'],
                    description=todo_data.get('description', '')
                )
                db.add(todo)

            db.commit()

            # Set the result for the future
            future.set_result({"detail": "To-dos generated successfully."})

            logger.info(f"To-dos generated successfully for transcription_id: {transcription_id}")

        except Exception as e:
            logger.error("Error during to-do generation:", exc_info=True)
            future.set_exception(Exception("Error during to-do generation"))
        finally:
            db.close()
            todo_queue.task_done()

# Function để khởi chạy background task
def start_background_tasks():
    loop = asyncio.get_event_loop()
    loop.create_task(process_queue())
    loop.create_task(process_todo_queue())
