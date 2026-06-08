import datetime

from db import SessionLocal
from fastapi import APIRouter, Depends, HTTPException
from models.sessions import Session
from sqlalchemy.orm import Session as DBSession

from routes.auth import UserModel, get_current_user

router = APIRouter()


def get_db():
    """Dependency to get the database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/list")
async def list_sessions(
    current_user: UserModel = Depends(get_current_user), db: DBSession = Depends(get_db)
):
    """List all sessions."""
    return db.query(Session).all()


@router.get("/{id}")
async def get_session(
    id: str,
    current_user: UserModel = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    """Get a session by ID."""
    session = db.query(Session).filter(Session.id == id).first()
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    return session


@router.delete("/{id}")
async def delete_session(
    id: str,
    current_user: UserModel = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    """Delete a session by ID."""
    session = db.query(Session).filter(Session.id == id).first()
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    db.delete(session)
    db.commit()
    return {"deleted": id}


@router.post("")
async def create_session(
    current_user: UserModel = Depends(get_current_user), db: DBSession = Depends(get_db)
):
    """Create a new session."""
    now = datetime.datetime.now().isoformat()
    new_session = Session(user_id=current_user.id, start=now, end=now)
    db.add(new_session)
    db.commit()
    db.refresh(new_session)
    return new_session
