# pydantic_schemas/user.py
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class AudioFileSchema(BaseModel):
    id: str
    title: str
    blob_name: str
    file_url: str
    uploaded_at: datetime

    class Config:
        orm_mode = True
        from_attributes = True

class UserSchema(BaseModel):
    id: str
    email: str
    name: str
    audio_files: List[AudioFileSchema] = []

    class Config:
        orm_mode = True
        from_attributes = True
