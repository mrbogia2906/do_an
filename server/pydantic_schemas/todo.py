# pydantic_schemas/todo.py
from pydantic import BaseModel
from typing import Optional

class TodoBase(BaseModel):
    title: str
    description: Optional[str] = None

class TodoCreate(TodoBase):
    pass

class TodoResponse(TodoBase):
    id: str
    transcription_id: str


class TodoWithAudioResponse(BaseModel):
    id: str
    transcription_id: str
    title: str
    description: str
    is_completed: bool
    audio_title: str

class TodoUpdate(TodoBase):
    title: str = None
    description: str = None
    is_completed: bool  = None

class TodoCreate2(BaseModel):
    transcription_id: str
    title: str
    description: str
    is_completed: bool = False
    class Config:
        orm_mode = True
