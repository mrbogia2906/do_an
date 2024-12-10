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
from google.cloud import storage, speech
import mimetypes
import json
import logging
from concurrent.futures import ThreadPoolExecutor
from functools import partial
from google.protobuf.json_format import MessageToDict



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

executor = ThreadPoolExecutor(max_workers=10)

# Khởi tạo client Google Speech-to-Text
speech_client = speech.SpeechClient()

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

async def run_blocking_io(func, *args, **kwargs):
    loop = asyncio.get_event_loop()
    partial_func = partial(func, *args, **kwargs)
    return await loop.run_in_executor(executor, partial_func)

def get_transcription_from_db(db: Session, transcription_id: str):
    return db.query(Transcription).filter(Transcription.id == transcription_id).first()

def upload_file_sync(file_path: str, mime_type: str):
    return genai.upload_file(path=file_path, mime_type=mime_type)

def get_file_metadata_sync(file_name: str):
    return genai.get_file(file_name)



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
        
        # Tạo Signed URL 
        signed_url = blob.generate_signed_url(expiration=timedelta(days=7), method='GET')
        
        return signed_url
    except Exception as e:
        print("Error uploading to GCS:", e)
        raise e


def clean_response(text):
    """Loại bỏ các ký tự không mong muốn như ```json và ``` từ phản hồi."""
    text = text.strip()
    if not text:  
        logger.error("Received an empty response.")
        return None
    if text.startswith("```json") and text.endswith("```"):
        text = text[len("```json"): -len("```")].strip()
    return text


def extract_json(text):
    """Trích xuất và làm sạch JSON từ phản hồi."""
    try:
        cleaned_text = clean_response(text)
        logger.debug(f"Raw response: {text}")
        logger.debug(f"Cleaned response: {cleaned_text}")
        if cleaned_text is None:
            logger.error("Cleaned response is None.")
            return None
        return json.loads(cleaned_text)
    except json.JSONDecodeError as e:
        logger.error(f"JSON decoding failed: {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error during JSON extraction: {e}")
        return None


async def process_queue():
    while True:
        file_location, transcription_id, future, service, languages, duration_seconds = await queue.get()
        try:
            # Khởi tạo session DB
            db: Session = SessionLocal()

            # Lấy bản ghi Transcription
            transcription = await run_blocking_io(get_transcription_from_db, db, transcription_id)
            if not transcription:
                raise Exception(f"Transcription with id {transcription_id} not found.")

            # Kiểm tra MIME type
            mime_type = "audio/mpeg"
            if not mime_type:
                raise ValueError(f"Unknown MIME type for file: {file_location}. Please set the 'mime_type' argument.")

            # Upload file lên File API
            logger.info(f"Uploading file {file_location} to File API.")
            uploaded_file = await run_blocking_io(upload_file_sync, file_location, mime_type)
            file_name = uploaded_file.name

            transcription_content = ""
            summary = ""

            if service == 'gemini':
                # Kiểm tra trạng thái xử lý của tệp (chỉ áp dụng cho Gemini)
                while True:
                    file_metadata = await run_blocking_io(get_file_metadata_sync, file_name)
                    logger.info(f"File metadata: {file_metadata}")
                    logger.info(f"File metadata state: {file_metadata.state}")

                    state = file_metadata.state.name.lower() if hasattr(file_metadata.state, 'name') else str(file_metadata.state).lower()

                    if state == "active":
                        logger.info(f"File {file_name} is active.")
                        break
                    elif state == "failed":
                        raise Exception("Audio processing failed in Gemini AI.")
                    else:
                        logger.info(f"File {file_name} is still processing. Waiting...")
                        await asyncio.sleep(10)  # Chờ 10 giây trước khi kiểm tra lại

                # Xử lý phiên âm bằng Gemini AI để lấy content
                model = genai.GenerativeModel(model_name="gemini-1.5-flash")

                # **Bước 1: Yêu cầu Gemini AI trả về content**
                prompt_content = (
                    "Please provide a transcription of the audio."
                )

                logger.info(f"Prompt for Content Transcription: {prompt_content}")

                # Gửi yêu cầu phiên âm để lấy content
                response_content = await run_blocking_io(
                    model.generate_content,
                    [
                        uploaded_file,
                        "\n\n",
                        prompt_content
                    ],
                    safety_settings={
                        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
                        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
                    }
                )

                # Kiểm tra finish_reason trước khi truy cập response.text
                if hasattr(response_content, 'finish_reason') and response_content.finish_reason == 4:
                    raise Exception("Transcription failed: Model detected copyrighted material.")

                # **Lấy kết quả phiên âm content**
                try:
                    transcription_text_content = response_content.text.strip()
                    logger.debug(f"Received transcription text for content: '{transcription_text_content}'")
                    transcription_content = transcription_text_content if transcription_text_content else "Transcription failed: Unable to retrieve transcription text."
                except Exception as e:
                    logger.error(f"Error extracting transcription content data: {e}")
                    transcription_content = "Transcription failed: Unable to retrieve transcription text."

                # **Bước 2: Yêu cầu Gemini AI tạo summary dựa trên content**
                if transcription_content and len(transcription_content) > 0 and not transcription_content.startswith("Transcription failed"):
                    prompt_summary = (
                        "Please provide a concise summary of the following transcription content. "
                        "The summary should capture the main points and key information.\n\n"
                        f"Transcription Content:\n{transcription_content}\n\nSummary:"
                    )

                    logger.info(f"Prompt for Summary Generation: {prompt_summary}")

                    # Gửi yêu cầu để tạo summary
                    response_summary = await run_blocking_io(
                        model.generate_content,
                        [
                            "",  # Không cần gửi file cho bước này
                            "\n\n",
                            prompt_summary
                        ],
                        safety_settings={
                            HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
                            HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
                        }
                    )

                    # Kiểm tra finish_reason trước khi truy cập response.text
                    if hasattr(response_summary, 'finish_reason') and response_summary.finish_reason == 4:
                        raise Exception("Summary generation failed: Model detected copyrighted material.")

                    # **Lấy kết quả summary**
                    try:
                        summary_text = response_summary.text.strip()
                        logger.debug(f"Received summary text: '{summary_text}'")
                        summary = summary_text if summary_text else "Summary failed: Unable to retrieve summary."
                    except Exception as e:
                        logger.error(f"Error extracting summary data: {e}")
                        summary = "Summary failed: Unable to retrieve summary."
                else:
                    summary = "Summary failed: Transcription content is empty or failed to retrieve."
            
            elif service == 'google':
                # Xử lý phiên âm bằng Google Speech-to-Text với danh sách ngôn ngữ
                transcription_result = await transcribe_with_google(file_location, languages)
                transcription_content = transcription_result['transcription']
                # Nếu cần summary với Google, bạn có thể thực hiện tương tự bước 2
                if transcription_content and len(transcription_content) > 0:
                    # Giả sử bạn sử dụng Gemini AI để tạo summary
                    model = genai.GenerativeModel(model_name="gemini-1.5-flash")
                    prompt_summary = (
                        "Please provide a concise summary of the following transcription content. "
                        "The summary should capture the main points and key information.\n\n"
                        f"Transcription Content:\n{transcription_content}\n\nSummary:"
                    )

                    logger.info(f"Prompt for Summary Generation: {prompt_summary}")

                    response_summary = await run_blocking_io(
                        model.generate_content,
                        [
                            "",  # Không cần gửi file cho bước này
                            "\n\n",
                            prompt_summary
                        ],
                        safety_settings={
                            HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
                            HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
                        }
                    )

                    if hasattr(response_summary, 'finish_reason') and response_summary.finish_reason == 4:
                        raise Exception("Summary generation failed: Model detected copyrighted material.")

                    try:
                        summary_text = response_summary.text.strip()
                        logger.debug(f"Received summary text: '{summary_text}'")
                        summary = summary_text if summary_text else "Summary failed: Unable to retrieve summary."
                    except Exception as e:
                        logger.error(f"Error extracting summary data: {e}")
                        summary = "Summary failed: Unable to retrieve summary."
                else:
                    summary = "Summary failed: Transcription content is empty."
            
            else:
                raise ValueError(f"Unknown transcription service: {service}")

            # Cập nhật bản ghi Transcription
            transcription.content = transcription_content
            transcription.summary = summary
            # Loại bỏ phần word_timings
            # transcription.word_timings = word_timings  # Không cần thiết
            transcription.is_processing = False
            transcription.is_error = False
            await run_blocking_io(db.commit)

            # Xóa tệp sau khi xử lý
            os.remove(file_location)

            # Đặt kết quả cho yêu cầu
            future.set_result({
                "id": transcription.id,
                "title": transcription.audio_file.title,
                "transcription": transcription.content,
                "summary": transcription.summary,
                # "word_timings": transcription.word_timings  # Không cần thiết
            })

        except Exception as e:
            if service == 'gemini':
                logger.error("Error during Gemini AI transcription:", exc_info=True)
            elif service == 'google':
                logger.error("Error during Google Speech-to-Text transcription:", exc_info=True)
            else:
                logger.error("Error during transcription:", exc_info=True)

            try:
                transcription = await run_blocking_io(get_transcription_from_db, db, transcription_id)
                if transcription:
                    transcription.is_processing = False
                    transcription.is_error = True
                    await run_blocking_io(db.commit)
            except Exception as db_e:
                logger.error(f"Error updating transcription status in DB: {db_e}", exc_info=True)

            future.set_exception(Exception("Error during transcription"))
        finally:
            await run_blocking_io(db.close)
            queue.task_done()



async def transcribe_with_google(file_location: str, language_codes: list = None):
    try:
        gcs_uri = f"gs://{os.getenv('GCS_BUCKET_NAME')}/{os.path.basename(file_location)}"
        audio = speech.RecognitionAudio(uri=gcs_uri)

        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.MP3,
            sample_rate_hertz=44100,
            language_code=language_codes[0] if language_codes else "en-US",
            alternative_language_codes=language_codes[1:] if language_codes and len(language_codes) > 1 else None,
            enable_word_time_offsets=True,
            model="default",
        )

        operation = speech_client.long_running_recognize(config=config, audio=audio)
        logger.info("Waiting for Google Speech-to-Text operation to complete...")
        response = operation.result(timeout=300)

        transcription_results = []
        for result in response.results:
            alternative = result.alternatives[0]
            for word_info in alternative.words:
                transcription_results.append({
                    "word": word_info.word,
                    "start_time": word_info.start_time.seconds + word_info.start_time.microseconds / 1e6,
                    "end_time": word_info.end_time.seconds + word_info.end_time.microseconds / 1e6,
                })

        transcription_content = " ".join([word['word'] for word in transcription_results])

        return {
            "transcription": transcription_content,
            "word_timings": transcription_results
        }

    except Exception as e:
        logger.error(f"Error during Google Speech-to-Text transcription: {e}", exc_info=True)
        raise e


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
def start_background_tasks(num_workers=5):
    loop = asyncio.get_event_loop()
    for _ in range(num_workers):
        loop.create_task(process_queue())
    loop.create_task(process_todo_queue())
