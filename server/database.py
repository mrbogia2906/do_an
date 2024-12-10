# database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
DATABASE_URL = 'postgresql+psycopg2://postgres:k235464@localhost:5432/speechtotextapp'
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit = False, autoflush=False, bind=engine)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()