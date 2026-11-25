# Kubernetes

The app is a stateless workload in the `platformops` namespace. The Deployment has two replicas, non-root UID 10001, restricted Pod Security Admission, read-only root filesystem, dropped capabilities, tokenless service account, resource bounds, startup/liveness/readiness probes, and zero-unavailable rolling updates. ConfigMap values are non-sensitive; no Kubernetes Secret is required by this service. The Service is ClusterIP; use port-forward for local access.

```bash
./scripts/create-cluster.sh
./scripts/build-image.sh dev
kind load docker-image platformops-deployment-platform:dev --name platformops
kubectl --context kind-platformops apply -k kubernetes/overlays/development
kubectl --context kind-platformops -n platformops rollout status deploy/platformops
kubectl --context kind-platformops -n platformops port-forward svc/platformops 8000:80
```

Inspect pods, endpoints, policy and events with `kubectl --context kind-platformops -n platformops get pods,svc,endpoints,networkpolicies,events`; use `describe`, `logs`, `exec`, `get pods -o wide`, and `port-forward` for diagnosis. ClusterIP is reachable within the cluster; NodePort exposes a port on cluster nodes; LoadBalancer requires an external load-balancer implementation. No external exposure is configured.

Kind's default CNI does not enforce NetworkPolicy, so policy YAML can be accepted without filtering traffic. The policy permits app and monitoring namespace ingress and DNS-only egress; enforcement must be verified with an enforcing CNI before relying on it. Network policies are additive. Service DNS is `<service>.<namespace>.svc.cluster.local`.

Kubernetes Secret data is base64 encoded, not inherently encrypted. Avoid real credentials here. For a real cluster, enable API encryption at rest, restrict RBAC access, mount secrets only into required containers, and prefer a managed external secret provider. The stateless app does not need PersistentVolumes, PersistentVolumeClaims, or StorageClasses. Two replicas on one node do not provide node-level high availability.
