# Enterprise Cloud & Microservices Target Repository

This repository is a fully functional, multi-tier benchmark codebase designed for automated compliance, security scanning, and infrastructure auditing tools.

Each component is self-contained, syntactically valid, and carries real business logic without placeholders or artificial stubs.

---

## Repository Structure

```text
.
├── infra/
│   ├── terraform/               # AWS S3 (SSE-KMS, lifecycle, public block) & SQS queue
│   ├── opentofu/                # Compute node with persistent EBS volume & env bootstrap
│   └── terragrunt/              # Staging environment orchestration pointing to Terraform
│
├── automation/
│   └── ansible/                 # Nginx deployment playbook with template & systemd management
│
├── apps/
│   ├── python/                  # FastAPI microservice with Pydantic validation & SHA-256
│   ├── javascript/              # Express.js HTTP API (health & user directory)
│   └── typescript/              # Strongly typed API client library with async methods
│
├── containers/
│   └── docker/                  # Multi-stage lightweight Dockerfile with non-root user
│
├── k8s/
│   ├── manifests/               # Kubernetes Deployment (2 replicas, probes, limits) & Service
│   └── helm/service-chart/      # Production-ready Helm 3 chart
│
├── scripts/
│   ├── powershell/              # Sync-Artifacts.ps1 with CmdletBinding & try/catch error handling
│   └── shell/                   # rotate_logs.sh with strict bash options and retention rules
│
└── docs/
    ├── README.md                # System architecture and API endpoint documentation
    └── getting-started.md       # Local execution and infrastructure deployment guide
```

---

## Component Highlights

| Directory | Technology | Core Functionality |
| :--- | :--- | :--- |
| `infra/terraform/` | Terraform HCL | AWS S3 bucket with customer-managed KMS key, lifecycle transitions, and dead-letter SQS queue. |
| `infra/opentofu/` | OpenTofu HCL | Compute instance with persistent encrypted EBS volume and environment variable injection. |
| `infra/terragrunt/` | Terragrunt | DRY wrapper feeding staging variables into the Terraform root module. |
| `automation/ansible/` | Ansible | Automated web tier configuration (Nginx installation, Jinja2 template deployment with 0644 permissions). |
| `apps/python/` | Python 3.11+ / FastAPI | Pydantic schema validation, timeouts on external HTTP requests, and deterministic identity hashing. |
| `apps/javascript/` | Node.js / Express | REST API exposing `/health` and `/api/users` with query filtering and PORT environment reading. |
| `apps/typescript/` | TypeScript | Strict interfaces (`UserResponse`, `ApiError`), type guards, and asynchronous fetch client. |
| `containers/docker/` | Docker | Multi-stage build on Python slim, non-root user creation (`10001:10001`), and HTTP health checks. |
| `k8s/manifests/` | Kubernetes | Deployment with 2 replicas, security contexts, probes, memory/CPU limits, and ClusterIP service. |
| `k8s/helm/service-chart/` | Helm 3 | Standardized chart with parameterized values, resource limits, and service definitions. |
| `scripts/powershell/` | PowerShell | Artifact synchronization tool supporting pipeline input, folder creation, and error traps. |
| `scripts/shell/` | Bash | Log rotation utility compressing logs older than 7 days and deleting archives older than 30 days. |
| `docs/` | Markdown | Comprehensive architecture, API contracts, and getting started procedures. |

---

## Intentionally non-compliant zone (`legacy/`)

`legacy/` holds deliberately bad code, one audit root per technology, so that every
control of the compliance engine is exercised twice: it must pass on the clean
folders above and report findings on `legacy/`. See `legacy/README.md` for the
findings each folder must produce. Do not fix this code.
