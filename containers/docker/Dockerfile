# Stage 1: Dependency resolution and compilation
FROM python:3.12.9-slim-bookworm AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /install

COPY apps/python/requirements.txt ./
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt


# Stage 2: Hardened runtime environment
FROM python:3.12.9-slim-bookworm AS runtime

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

LABEL maintainer="Platform Engineering <devops@example.com>" \
      version="1.0.0" \
      description="Lightweight hardened Python microservice container"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

# Create dedicated unprivileged system user
RUN groupadd --system --gid 10001 appgroup && \
    useradd --system --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

# Copy runtime assets with correct ownership
COPY --from=builder --chown=appuser:appgroup /opt/venv /opt/venv
COPY --chown=appuser:appgroup apps/python/service.py /app/service.py

USER 10001:10001

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3)" || exit 1

ENTRYPOINT ["python", "-m", "uvicorn", "service:app", "--host", "0.0.0.0", "--port", "8000"]
