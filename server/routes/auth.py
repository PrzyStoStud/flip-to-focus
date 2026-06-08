from datetime import timedelta

import jwt
from core.security import (
    ACCESS_TOKEN_EXPIRE_MINUTES,
    ALGORITHM,
    SECRET_KEY,
    create_access_token,
    get_password_hash,
    verify_password,
)
from db import SessionLocal
from fastapi import APIRouter, Depends, Form, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from models.user import User as UserModel
from pydantic import BaseModel
from sqlalchemy.orm import Session as DBSession

router = APIRouter()


class Token(BaseModel):
    access_token: str
    token_type: str
    expires_in: int


class User(BaseModel):
    id: str
    email: str

    class Config:
        orm_mode = True


class UserCreate(BaseModel):
    email: str
    password: str


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token")


# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


async def get_current_user(
    token: str = Depends(oauth2_scheme), db: DBSession = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception
    user = db.query(UserModel).filter(UserModel.email == username).first()
    if user is None:
        raise credentials_exception
    return user


@router.post("/register", response_model=User)
async def register(user: UserCreate, db: DBSession = Depends(get_db)):
    """Register a new user."""
    if len(user.password) > 72:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Password cannot be longer than 72 characters.",
        )
    if len(user.password) < 8:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Password must be at least 8 characters long.",
        )
    db_user = db.query(UserModel).filter(UserModel.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    hashed_password = get_password_hash(user.password)
    new_user = UserModel(email=user.email, password_hash=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.post("/token", response_model=Token)
async def token(
    grant_type: str = Form(...),
    username: str = Form(None),
    password: str = Form(None),
    db: DBSession = Depends(get_db),
):
    """
    OAuth2-compliant token endpoint
    """
    user = None

    if grant_type == "password":
        if not username or not password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing username or password",
            )

        user = db.query(UserModel).filter(UserModel.email == username).first()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials",
            )

        # IMPORTANT: use your REAL field name (from your working code)
        if not verify_password(password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials",
            )

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported grant_type",
        )

    access_token = create_access_token(
        data={"sub": user.email},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )

    return {
        "access_token": access_token,
        "token_type": "Bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }


@router.get("/me", response_model=User)
async def me(current_user: UserModel = Depends(get_current_user)):
    """Get the current user."""
    return current_user


@router.post("/remove")
async def remove(
    current_user: UserModel = Depends(get_current_user), db: DBSession = Depends(get_db)
):
    """Remove the user."""
    db.delete(current_user)
    db.commit()
    return {"message": "removed"}


@router.post("/logout")
async def logout():
    """Logout a user."""
    return {"message": "logged out"}
