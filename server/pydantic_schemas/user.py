# pydantic_schemas/user.py
from pydantic import BaseModel, Field, constr
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
    is_premium: bool
    max_audio_files: int 
    max_total_audio_time: int
    total_audio_time: int

    class Config:
        orm_mode = True
        from_attributes = True
        allow_population_by_field_name = True

class UpdateUsernameRequest(BaseModel):
    new_username: constr(min_length=3, max_length=50)

class UpdatePasswordRequest(BaseModel):
    old_password: str
    new_password: constr(min_length=6)

class UpdateResponse(BaseModel):
    message: str