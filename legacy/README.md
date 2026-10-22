# Legacy zone - intentionally non-compliant

Everything under `legacy/` is **deliberately bad code** ("spaghetti").
Each folder is its own audit root and must make its controls report findings,
while the clean folders (`apps/`, `infra/`, `k8s/`, ...) must pass.
Do not fix this code: the compliance engine tests rely on these defects.

| Folder | Expected findings |
| --- | --- |
| `terraform/` | `terraform fmt`, TFLint, Checkov (public bucket, open security group) |
| `opentofu/` | `tofu fmt`, Checkov |
| `terragrunt/` | `terragrunt hclfmt` |
| `ansible/` | yamllint, ansible-lint (Linux and macOS) |
| `python/` | Ruff, Pylint, Bandit, pytest failure, pip-audit (unpinned and vulnerable pins) |
| `powershell/` | PSScriptAnalyzer |
| `docker/` | Hadolint, Trivy |
| `k8s/` | Checkov, Trivy (privileged pod) |
| `shell/` | ShellCheck |
| `javascript/` | ESLint, Gitleaks (fake generic secret) |
| `typescript/` | `tsc` type errors, ESLint |
| `docs/` | rumdl |
