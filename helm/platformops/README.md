# Helm chart

The chart parameterizes replicas, image repository/tag, service, optional ingress, resources, probes, settings, security context, autoscaling and network policy. `values-development.yaml` is for local iteration; `values-production.yaml` is a starting point only and its repository/tag must be replaced with a reviewed immutable GHCR tag. Do not deploy it as-is.

```bash
helm lint helm/platformops -f helm/platformops/values-development.yaml
helm template platformops helm/platformops -n platformops -f helm/platformops/values-development.yaml --set image.tag=<tag>
helm upgrade --install platformops helm/platformops -n platformops --create-namespace -f helm/platformops/values-development.yaml --set-string image.tag=<tag> --wait
helm history platformops -n platformops
helm rollback platformops <revision> -n platformops --wait
helm uninstall platformops -n platformops
```

Helm owns its release objects and revision history; raw manifests in `kubernetes/base` are useful for review and Kustomize validation but should not manage the same workload simultaneously. HPA requires a functioning metrics API such as metrics-server; the chart disables autoscaling by default. Ingress is disabled by default and requires an installed ingress controller. Kind's default CNI may not enforce NetworkPolicy.
