from fastapi import APIRouter, Response

from platformops.metrics import metrics_payload

router = APIRouter(tags=["metrics"])


@router.get("/metrics", include_in_schema=False)
def metrics() -> Response:
    body, content_type = metrics_payload()
    return Response(content=body, media_type=content_type)
