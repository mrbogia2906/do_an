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

    class Config:
        orm_mode = True
