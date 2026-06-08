from fastapi import APIRouter

router = APIRouter()


@router.get("/list")
async def list_sessions():
    return []


@router.get("/{uuid}")
async def get_session(uuid: str):
    return {"uuid": uuid}


@router.delete("/{uuid}")
async def delete_session(uuid: str):
    return {"deleted": uuid}


@router.post("")
async def create_session():
    return {"created": True}
