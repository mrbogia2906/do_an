import uuid
import bcrypt
from fastapi import Depends, HTTPException
from fastapi import APIRouter
from sqlalchemy.orm import Session
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin
from pydantic_schemas.user import UserSchema  # Import schema
import jwt

from middleware.auth_middleware import auth_middleware
from database import get_db

router = APIRouter()

@router.post('/signup', response_model=UserSchema, status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    # Kiểm tra xem người dùng đã tồn tại chưa
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(400, 'User with the same email already exists!')

    # Mã hóa mật khẩu
    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(
        id=str(uuid.uuid4()),
        email=user.email,
        password=hashed_pw.decode(),  # Đảm bảo mật khẩu là string
        name=user.name
    )

    # Thêm người dùng vào cơ sở dữ liệu
    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db

@router.post('/login', response_model=dict)  # Bạn có thể định nghĩa một schema riêng cho response
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    # Kiểm tra xem người dùng có tồn tại không
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(400, 'User with this email does not exist!')

    # Kiểm tra mật khẩu
    if isinstance(user_db.password, memoryview):
        hashed_password = user_db.password.tobytes()
    elif isinstance(user_db.password, str):
        hashed_password = user_db.password.encode()
    else:
        hashed_password = user_db.password

    is_match = bcrypt.checkpw(user.password.encode(), hashed_password)

    if not is_match:
        raise HTTPException(400, 'Incorrect password!')

    token = jwt.encode({'id': user_db.id}, 'password_key')

    return {'token': token, 'user': UserSchema.from_orm(user_db)}

@router.get('/', response_model=UserSchema)
def current_user_data(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).first()

    if not user:
        raise HTTPException(404, 'User not found!')

    return UserSchema.from_orm(user)  # Sử dụng Pydantic schema