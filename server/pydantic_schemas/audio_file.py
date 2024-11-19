# schemas/audio_file.py

from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AudioFileUpdateTitle(BaseModel):
    title: str


class AudioFileResponse(BaseModel):
    id: str
    user_id: str
    title: str
    blob_name: Optional[str]
    file_url: str
    uploaded_at: datetime

    class Config:
        orm_mode = True