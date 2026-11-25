"""Centralized environment-backed application settings."""

import os
from dataclasses import dataclass

from platformops import __version__


@dataclass(frozen=True, slots=True)
class Settings:
    app_name: str = "PlatformOps API"
    app_version: str = __version__
    environment: str = "development"
    build_revision: str = "unknown"
    build_date: str = "unknown"
    log_level: str = "INFO"

    @classmethod
    def from_environment(cls) -> "Settings":
        """Load the documented application settings without exposing the environment."""
        log_level = os.getenv("LOG_LEVEL", "INFO").upper()
        if log_level not in {"DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"}:
            log_level = "INFO"
        return cls(
            app_name=os.getenv("APP_NAME", "PlatformOps API"),
            app_version=os.getenv("APP_VERSION", __version__),
            environment=os.getenv("APP_ENVIRONMENT", "development"),
            build_revision=os.getenv("BUILD_REVISION", "unknown"),
            build_date=os.getenv("BUILD_DATE", "unknown"),
            log_level=log_level,
        )


settings = Settings.from_environment()
