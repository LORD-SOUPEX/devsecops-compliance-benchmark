# Getting Started Guide

This guide describes how to run and deploy the enterprise application suite and its infrastructure components locally and in cloud environments.

## Prerequisites

Before executing or deploying any service, verify that the following runtime engines are accessible:

- **Node.js** >= 18.0.0
- **Python** >= 3.11 with `pip`
- **Docker Engine** >= 24.0
- **AWS CLI** configured with appropriate IAM credentials (for Terraform & OpenTofu)
- **Kubectl** and a target Kubernetes cluster (Minikube, Kind, or EKS)

## Running Application Services Locally

### 1. User Verification Microservice (Python)

Navigate to the Python application directory and install dependencies:

```bash
cd apps/python
pip install -r requirements.txt
python service.py
```

The service launches on `http://localhost:8000`. API documentation is automatically accessible at `http://localhost:8000/docs`.

### 2. User Directory Server (JavaScript)

Navigate to the JavaScript directory, install runtime dependencies, and start the HTTP server:

```bash
cd apps/javascript
npm install
npm start
```

The Express.js server listens on port `3000` (or the port defined by `PORT`).

### 3. Compiling the TypeScript API Client

Validate client types and definitions:

```bash
cd apps/typescript
npx tsc --noEmit
```

## Infrastructure Deployment

### Deploying Storage and Queue Baseline with Terraform

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

### Terragrunt Orchestration

To run with environment parameters managed by Terragrunt:

```bash
cd infra/terragrunt
terragrunt plan
terragrunt apply
```

### Container Deployment with Kubernetes

```bash
kubectl apply -f k8s/manifests/deployment.yaml
kubectl apply -f k8s/manifests/service.yaml
```

Inspect the rollout status:

```bash
kubectl rollout status deployment/user-service-deployment
```
