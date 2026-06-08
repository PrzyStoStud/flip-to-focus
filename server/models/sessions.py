import uuid

from db import Base
from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column


class Session(Base):
    __tablename__ = "sessions"

    id: Mapped[str] = mapped_column(primary_key=True, default=lambda: str(uuid.uuid4()))

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    start: Mapped[str]
    end: Mapped[str]
