# Networking

The app listens on container port 8000. A ClusterIP Service named `platformops` maps port 80 to that named target port. Cluster DNS resolves `platformops.platformops.svc.cluster.local`. The baseline path for a workstation is `kubectl port-forward service/platformops 8000:80`; it binds locally and does not require a NodePort or external load balancer.

Pods receive cluster IPs and are selected by `app.kubernetes.io/name`. Readiness controls Service endpoint membership. NetworkPolicy limits app ingress to same-namespace workloads and monitoring namespace, and egress to DNS ports. Kind's default networking may accept but not enforce policies; verify enforcement with controlled connectivity probes before relying on it. Ingress requires an ingress controller, host mapping, and local TLS/configuration decisions; it is intentionally optional.

Troubleshooting: inspect `kubectl get pods -o wide`, `get svc`, `get endpoints`, `get ingress`, `get networkpolicies`, `describe pod`, `logs`, and `exec`. Verify DNS with `nslookup platformops.platformops.svc.cluster.local` in a debug Pod if one is available. Check Service selector and Pod labels, target port 8000, readiness condition, EndpointSlices and policy ingress. Use `kubectl port-forward` to distinguish Service routing from client exposure.
