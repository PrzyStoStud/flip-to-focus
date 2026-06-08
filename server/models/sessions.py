import uuid
from datetime import datetime

from db import Base
from sqlalchemy import DateTime, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column


class Session(Base):
    __tablename__ = "sessions"

    id: Mapped[str] = mapped_column(primary_key=True, default=lambda: str(uuid.uuid4()))

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)

    start: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    end: Mapped[datetime] = mapped_column(DateTime, nullable=True)
