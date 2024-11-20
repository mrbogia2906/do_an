# models/todo.py
from sqlalchemy import Column, String, ForeignKey, Text
from sqlalchemy.orm import relationship
from models.base import Base
from uuid import uuid4

class Todo(Base):
    __tablename__ = 'todos'

    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    transcription_id = Column(String, ForeignKey('transcriptions.id'), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)

    transcription = relationship("Transcription", back_populates="todos")
