# schemas/transcription.py
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

from pydantic_schemas.todo import TodoResponse

class WordTiming(BaseModel):
    word: str
    start_time: float
    end_time: float

class TranscriptionResponse(BaseModel):
    id: str
    audio_file_id: str
    content: Optional[str]
    word_timings: Optional[List[WordTiming]]
    created_at: datetime
    is_processing: bool
    is_error: bool
    todos: List[TodoResponse] = []

    class Config:
        orm_mode = True
