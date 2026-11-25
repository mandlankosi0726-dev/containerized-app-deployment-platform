FROM python:3.12.8-slim-bookworm AS build
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_NO_CACHE_DIR=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /build
COPY requirements.lock ./requirements.lock
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.lock

FROM python:3.12.8-slim-bookworm AS runtime
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENVIRONMENT=production \
    PORT=8000
RUN groupadd --system --gid 10001 platformops \
    && useradd --system --uid 10001 --gid platformops --home-dir /app --no-create-home platformops
WORKDIR /app
COPY --from=build /opt/venv /opt/venv
COPY --chown=10001:10001 src/ /app/src/
USER 10001:10001
EXPOSE 8000
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "from urllib.request import urlopen; urlopen('http://127.0.0.1:8000/health', timeout=2)" || exit 1
ENTRYPOINT ["uvicorn", "platformops.main:app", "--app-dir", "/app/src", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
