# Security operations

See [SECURITY.md](../SECURITY.md) for scope and policy. The service does not accept credentials, authorization data or persistent user input. It returns only curated metadata and does not list environment variables. Structured logs record method, route template, status and duration while omitting query strings and request bodies.

The image and Pods run non-root with dropped capabilities, no privilege escalation, seccomp RuntimeDefault, read-only root filesystem and explicit resource bounds. The workload has no Kubernetes API access. Namespace Pod Security Admission is set to `restricted`. ConfigMap stores only non-secret values. Do not add credentials to ConfigMaps, values files or workflow YAML.

Kubernetes Secret `data` is base64 encoding. A production cluster must enable encryption at rest, limit Secret read permissions, audit access and consider an external secret manager. CI's publish workflow uses `GITHUB_TOKEN` with `packages: write`; PR CI has no package write token. Trivy config/image scans and pip-audit are wired into workflows, but they have not passed a live GitHub Actions run in this local workspace.

Before any production use, pin third-party actions to immutable commit SHAs, enforce trusted branch protection and required reviews, sign/verify artifacts, use digest pinning, add SBOM/license review, configure an enforcing CNI and ingress TLS/auth controls, and run an independent threat review.
