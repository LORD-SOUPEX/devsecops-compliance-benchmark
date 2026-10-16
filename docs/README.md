# Enterprise Cloud Architecture & Services Documentation

Welcome to the central documentation for the Enterprise Cloud & Microservices benchmark repository. This document outlines the overall architecture, communication contracts, API endpoints, and infrastructure components.

## System Architecture Overview

The system is partitioned into autonomous tiers designed for cloud-native deployment:

- **Storage & Ingestion Tier (`infra/terraform/`, `infra/terragrunt/`)**: AWS S3 object storage with KMS SSE encryption, versioning, automated lifecycle transitions (Standard-IA to Glacier), and an asynchronous dead-letter-backed SQS event queue.
- **Compute Tier (`infra/opentofu/`)**: OpenTofu managed compute nodes with attached encrypted EBS persistent storage and systemd service bootstrap.
- **Microservices Tier (`apps/`)**:
  - Python FastAPI microservice (`apps/python/`): Validates incoming user registration payloads, computes deterministic SHA-256 identity hashes, and executes external dependency checks with timeouts.
  - Express.js User Directory (`apps/javascript/`): Lightweight Node.js server exposing health probes and user directory query endpoints.
  - TypeScript Client Library (`apps/typescript/`): Strongly typed consumer module with strict error mapping and array transformations.
- **Containerization & Orchestration (`containers/`, `k8s/`)**: Hardened non-root multi-stage Docker images deployed across Kubernetes via manifests and standardized Helm 3 charts.
- **Automation & Operations (`automation/`, `scripts/`)**: Idempotent Ansible playbooks for Nginx web tier configuration, PowerShell artifact synchronization, and POSIX log lifecycle maintenance.

## API Endpoints Specification

### 1. User Verification Microservice (Python / FastAPI)

| Method | Route | Description | Request / Response Format |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Uptime and service status probe | `{"status": "healthy", "service": "user-verification"}` |
| `POST` | `/api/users/verify` | Validates profile and computes privacy hash | Body: `{"username": string, "email": string, "account_tier": string}` |
| `GET` | `/docs` | Interactive OpenAPI Swagger UI documentation | HTML / OpenAPI Schema |

### 2. User Directory Service (JavaScript / Express)

| Method | Route | Description | Query Parameters / Payload |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Container health probe with uptime counter | `{"status": "UP", "uptimeSeconds": number}` |
| `GET` | `/api/users` | List users with optional role filtering | Query: `?role=admin\|developer\|viewer` |
| `POST` | `/api/users` | Registers a new user into memory store | Body: `{"username": string, "role": string}` |

## Next Steps and Guides

For step-by-step instructions on deploying and testing these services locally, refer to the [Getting Started Guide](getting-started.md).
