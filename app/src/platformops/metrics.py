"""Low-cardinality HTTP metrics in Prometheus exposition format."""

from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

REQUESTS = Counter(
    "platformops_http_requests_total",
    "Completed HTTP requests",
    ("method", "path", "status"),
)
LATENCY = Histogram(
    "platformops_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ("method", "path"),
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5),
)


def metrics_payload() -> tuple[bytes, str]:
    return generate_latest(), CONTENT_TYPE_LATEST
