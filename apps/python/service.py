"""User verification and telemetry microservice.

Provides schema validation via Pydantic, secure SHA-256 identifier hashing,
and external health check resolution with strict HTTP timeouts.
"""

from __future__ import annotations

import hashlib
import logging
from typing import Any

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
import requests

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("service")

app = FastAPI(
    title="User Telemetry & Verification Service",
    version="1.0.0",
    docs_url="/docs",
)


class UserProfileRequest(BaseModel):
    """Incoming user registration and verification payload."""

    username: str = Field(min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_-]+$")
    email: EmailStr
    account_tier: str = Field(default="standard", pattern=r"^(standard|premium|enterprise)$")


class UserProfileResponse(BaseModel):
    """Sanitized response returning user metadata and hashed identity."""

    username: str
    email: str
    account_tier: str
    identity_hash: str


def generate_secure_identity_hash(email: str, username: str) -> str:
    """Generate deterministic SHA-256 identity hash for privacy-safe correlation.

    Args:
        email: Verified user email address.
        username: Chosen user identifier.

    Returns:
        Hex-encoded SHA-256 digest string.
    """
    raw_identity = f"{email.strip().lower()}:{username.strip().lower()}"
    return hashlib.sha256(raw_identity.encode("utf-8")).hexdigest()


def fetch_upstream_service_status(endpoint_url: str, timeout_seconds: float = 5.0) -> dict[str, Any]:
    """Execute external status probe enforcing explicit connection and read timeouts.

    Args:
        endpoint_url: Target URL to query.
        timeout_seconds: Maximum duration before raising Timeout.

    Returns:
        JSON response payload from upstream service.
    """
    try:
        response = requests.get(
            endpoint_url,
            timeout=timeout_seconds,
            headers={"User-Agent": "SecOps-TelemetryService/1.0"},
        )
        response.raise_for_status()
        return response.json()
    except requests.exceptions.Timeout as exc:
        logger.error("Upstream request timed out: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="Upstream dependency timed out",
        ) from exc
    except requests.exceptions.RequestException as exc:
        logger.error("Upstream request failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to communicate with upstream service",
        ) from exc


@app.get("/health", tags=["System"])
def get_health() -> dict[str, str]:
    """Basic service health check."""
    return {"status": "healthy", "service": "user-verification"}


@app.post("/api/users/verify", response_model=UserProfileResponse, tags=["Users"])
def verify_user(payload: UserProfileRequest) -> UserProfileResponse:
    """Validate user profile and compute non-reversible privacy hash."""
    hashed_id = generate_secure_identity_hash(payload.email, payload.username)
    logger.info("Processed verification for user: %s", payload.username)

    return UserProfileResponse(
        username=payload.username,
        email=payload.email,
        account_tier=payload.account_tier,
        identity_hash=hashed_id,
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
