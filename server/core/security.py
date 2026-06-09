import os
from datetime import datetime, timedelta

import jwt

SECRET = os.environ["API_SECRET_KEY"]


def create_token(user_id: int):
    payload = {"sub": str(user_id), "exp": datetime.utcnow() + timedelta(days=7)}

    return jwt.encode(payload, SECRET, algorithm="HS256")
