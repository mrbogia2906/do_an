from fastapi import FastAPI
from models.base import Base
from routes import auth, transcribe, payment, search
from database import engine
import background
import asyncio

from fastapi import FastAPI
from routes import auth, transcribe, payment, search
app = FastAPI()
app.include_router(auth.router, prefix='/auth', tags=["Authentication"])
app.include_router(transcribe.router, prefix='/api', tags=["Audio Transcription"])
app.include_router(payment.router, prefix="/api", tags=["Payment"])
app.include_router(search.router, prefix="/api", tags=["Search"])
Base.metadata.create_all(engine)

# Sự kiện khởi động ứng dụng để bắt đầu xử lý hàng đợi
@app.on_event("startup")
async def startup_event():
    num_workers = 5 
    background.start_background_tasks(num_workers)

@app.on_event("shutdown")
async def shutdown_event():
    await background.queue.join()
    await background.todo_queue.join()
