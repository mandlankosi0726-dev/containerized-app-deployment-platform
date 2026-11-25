"""FastAPI entry point."""

import logging
import time
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from platformops import __version__
from platformops.config import settings
from platformops.logging_config import configure_logging
from platformops.metrics import LATENCY, REQUESTS
from platformops.routes.health import router as health_router
from platformops.routes.information import router as information_router
from platformops.routes.metrics import router as metrics_router

configure_logging(settings.log_level)
logger = logging.getLogger("platformops.http")


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.ready = True
    logger.info("application_started", extra={"status_code": 200})
    yield
    app.state.ready = False
    logger.info("application_stopped", extra={"status_code": 200})


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version or __version__,
    description="Stateless workload for practicing container deployment operations.",
    lifespan=lifespan,
)


@app.middleware("http")
async def observe_requests(request: Request, call_next: Any):
    started = time.perf_counter()
    status_code = 500
    try:
        response = await call_next(request)
        status_code = response.status_code
        return response
    finally:
        duration = time.perf_counter() - started
        route = request.scope.get("route")
        path = getattr(route, "path", "unmatched")
        if path != "/metrics":
            REQUESTS.labels(request.method, path, str(status_code)).inc()
            LATENCY.labels(request.method, path).observe(duration)
        logger.info(
            "request_completed",
            extra={
                "method": request.method,
                "path": path,
                "status_code": status_code,
                "duration_ms": round(duration * 1000, 3),
            },
        )


@app.exception_handler(Exception)
async def unexpected_error_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.exception("unhandled_application_error", extra={"path": request.url.path})
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})


app.include_router(health_router)
app.include_router(information_router)
app.include_router(metrics_router)
