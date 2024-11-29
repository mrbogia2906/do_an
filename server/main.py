from fastapi import FastAPI
from models.base import Base
from routes import auth, transcribe, payment
from database import engine
import background
import asyncio

app = FastAPI()

# Bao gồm các router
app.include_router(auth.router, prefix='/auth', tags=["Authentication"])
app.include_router(transcribe.router, prefix='/api', tags=["Audio Transcription"])
app.include_router(payment.router, prefix="/api", tags=["Payment"])

# Tạo tất cả các bảng trong database
Base.metadata.create_all(engine)

# Sự kiện khởi động ứng dụng để bắt đầu xử lý hàng đợi
@app.on_event("startup")
async def startup_event():
    background.start_background_tasks()
