from fastapi import FastAPI
from routes import auth, sessions

app = FastAPI(title="Flip to Focus", version="1.0.0")

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(sessions.router, prefix="/sessions", tags=["sessions"])
