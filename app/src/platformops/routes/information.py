import platform
import sys

from fastapi import APIRouter

from platformops.config import settings

router = APIRouter(tags=["information"])


@router.get("/")
def landing() -> dict[str, str]:
    return {
        "application": settings.app_name,
        "version": settings.app_version,
        "environment": settings.environment,
        "status": "running",
        "platform": "PlatformOps container deployment platform",
    }


@router.get("/api/v1/info")
def information() -> dict[str, str]:
    return {
        "application": settings.app_name,
        "version": settings.app_version,
        "build_revision": settings.build_revision,
        "build_date": settings.build_date,
        "environment": settings.environment,
        "python_version": platform.python_version(),
        "runtime": "CPython",
    }


@router.get("/api/v1/system")
def system() -> dict[str, str]:
    """Return deliberately limited platform facts, never environment or host identifiers."""
    return {
        "python_version": sys.version.split()[0],
        "operating_system": platform.system(),
        "architecture": platform.machine(),
    }
