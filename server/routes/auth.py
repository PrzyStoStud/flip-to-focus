from fastapi import APIRouter, Depends

router = APIRouter()


@router.post("/register")
async def register():
    return {"message": "registered"}


@router.post("/login")
async def login():
    return {"token": "jwt-token"}


@router.get("/me")
async def me():
    return {"user": "current"}


@router.post("/remove")
async def remove():
    return {"message": "removed"}


@router.post("/logout")
async def logout():
    return {"message": "logged out"}
