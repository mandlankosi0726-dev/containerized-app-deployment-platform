# Cost management

The default development path is local Python, Docker and Kind and incurs no cloud charges. Local CPU, RAM and disk are consumed by the cluster, images, and optional Prometheus/Grafana. The Kind cluster is a single node, and no persistent monitoring storage is configured. Do not run broad Docker cleanup; inspect `docker system df` and remove only resources you personally created after review.

GHCR publication can consume Actions minutes and registry storage. AWS/EKS, public load balancers, NAT gateways, managed databases, hosted monitoring and public DNS are not provisioned. Any future cloud deployment requires a separately reviewed architecture, explicit approval, budget/cost estimate, and cleanup plan.
