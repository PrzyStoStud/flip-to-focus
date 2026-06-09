import time
from contextlib import asynccontextmanager

from alembic import command
from alembic.config import Config
from fastapi import FastAPI, Request
from routes import auth, sessions


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Run migrations
    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")
    yield


app = FastAPI(title="Flip to Focus", version="1.0.0", lifespan=lifespan)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    body = await request.body()
    print(f"DEBUG: Request {request.method} {request.url}")
    print(f"DEBUG: Headers: {dict(request.headers)}")
    print(f"DEBUG: Body: {body.decode() if body else 'None'}")

    # Since we read the body, we need to replace it so the next handlers can read it
    async def receive():
        return {"type": "http.request", "body": body, "more_body": False}

    request._receive = receive

    response = await call_next(request)

    # Capture response body
    response_body = b""
    async for chunk in response.body_iterator:
        response_body += chunk

    process_time = time.time() - start_time
    print(f"DEBUG: Response status: {response.status_code} took {process_time:.4f}s")
    print(
        f"DEBUG: Response Body: {response_body.decode() if response_body else 'None'}"
    )

    from fastapi.responses import Response

    return Response(
        content=response_body,
        status_code=response.status_code,
        headers=dict(response.headers),
        media_type=response.media_type,
    )


app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(sessions.router, prefix="/sessions", tags=["sessions"])
