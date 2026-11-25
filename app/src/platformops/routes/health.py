from fastapi import APIRouter, Request

router = APIRouter(tags=["health"])


@router.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/live")
def live() -> dict[str, str]:
    return {"status": "alive"}


@router.get("/ready")
def ready(request: Request) -> dict[str, str]:
    if not request.app.state.ready:
        from fastapi import HTTPException

        raise HTTPException(status_code=503, detail="Application is not ready")
    return {"status": "ready"}
