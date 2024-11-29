# routes/payment.py
import uuid
from fastapi import APIRouter, HTTPException, Depends, Request
from sqlalchemy.orm import Session
from models.user import User
from models.subscription import Subscription
from database import get_db
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/payment/callback")
async def payment_callback(request: Request, db: Session = Depends(get_db)):
    """
    Endpoint để xử lý callback từ ZaloPay.
    """
    try:
        # Giả sử ZaloPay gửi dữ liệu dưới dạng JSON
        data = await request.json()

        # Xử lý dữ liệu thanh toán
        user_id = data.get('user_id')  # Tùy thuộc vào cấu trúc dữ liệu callback của ZaloPay
        payment_status = data.get('status')  # Ví dụ: 'success', 'failed'

        if payment_status != 'success':
            logger.info(f"Thanh toán không thành công cho user_id: {user_id}")
            return {"message": "Payment not successful."}

        # Lấy người dùng từ DB
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            logger.error(f"User với ID {user_id} không tồn tại.")
            raise HTTPException(status_code=404, detail="User not found.")

        # Cập nhật trạng thái premium cho người dùng
        user.is_premium = True
        user.max_audio_files = 100  # Ví dụ: tăng lên 100 file
        user.max_total_audio_time = 86400  # Ví dụ: tăng lên 24 giờ (86400 giây)

        # Thêm vào bảng Subscription
        new_subscription = Subscription(
            id=str(uuid.uuid4()),
            user_id=user_id,
            plan='premium'
        )
        db.add(new_subscription)

        db.commit()

        logger.info(f"Nâng cấp tài khoản thành công cho user_id: {user_id}")

        return {"message": "Subscription updated successfully"}

    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error("Lỗi trong xử lý callback thanh toán:", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal Server Error")
