# CI/CD

Pull requests and pushes to `main` run pinned Python dependencies, Ruff lint/format, pytest with coverage, Docker build validation, Trivy configuration scan, Kustomize build and Helm lint/template checks. A scheduled/dispatch dependency workflow runs pip-audit. On trusted pushes to `main` and version tags, the container workflow builds and publishes SHA and release tags to GHCR using the job-scoped `GITHUB_TOKEN`; pull requests do not receive registry write permission.

The repository does not have an associated GitHub remote in this workspace, so workflow execution and GHCR publication cannot be validated here. No GitHub secrets should be needed for the standard registry push. Local deployment is deliberately operator-driven via `scripts/deploy.sh <immutable-tag>` after building and loading an image into the dedicated Kind cluster. This avoids pretending a GitHub-hosted runner can access a developer's local Kind cluster. Cloud credentials and production deployment are out of scope.

Workflow validation available locally is recorded in the project checklist. Failed test, manifest or security checks stop CI. Deployment validation is `helm upgrade --wait` followed by `kubectl rollout status`; rollback selects a previous Helm revision using `scripts/rollback.sh <revision>`.
