# Security policy

## Scope and threat model

This repository is a local deployment demonstration. The threat model includes malformed HTTP requests, accidental disclosure in logs or metadata, vulnerable dependencies or base images, compromised build workflows, and over-privileged workloads. It does not claim production certification, tenant isolation, or protection from a compromised workstation or Kubernetes administrator.

## Controls

- The app exposes only selected settings and minimal runtime facts; logs omit query strings, headers and bodies.
- The image uses a pinned Python slim base tag, controlled Python dependencies and UID 10001.
- Compose and Kubernetes drop capabilities, disallow privilege escalation and use read-only root filesystems.
- Kubernetes disables service-account token mounting and sets restricted pod security on the namespace.
- Kubernetes manifests define resource requests/limits, probes and a default-deny NetworkPolicy.
- CI uses read-only contents permission; the trusted push workflow receives package write permission only and uses GitHub's short-lived token.
- Trivy and pip-audit checks are wired into CI; scan results must be reviewed and fixed, not suppressed without rationale.

## Secrets

Do not commit credentials, tokens, private keys, kubeconfigs or real `.env` files. Kubernetes Secret values are base64-encoded and are not encrypted by that encoding. Real clusters need API encryption at rest, least-privilege RBAC, audit logging and preferably a managed external secret provider. No production secret integration is configured here.

## Known weaknesses and response

The API has no authentication because it serves demo metadata only. The baseline Kind networking may not enforce NetworkPolicy. Workflow actions use major-version tags and should be pinned to reviewed commit SHAs before production use. The Docker base image uses an explicit patch tag but should be refreshed through a controlled update process. Metrics are process-local. Report security issues privately to the repository owner; rotate any credential that may have been exposed and remove it from history as well as the working tree.
