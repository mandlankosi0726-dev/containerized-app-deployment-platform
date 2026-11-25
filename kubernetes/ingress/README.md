# Ingress extension

The local baseline uses a ClusterIP Service and loopback `kubectl port-forward`, so it does not install an ingress controller or expose host ports. To exercise Ingress, first install and verify an ingress controller compatible with the chosen Kind cluster, add a host rule in Helm values, and configure a local-only hosts entry if desired. Traffic should follow local client → controller Service → Ingress rule → `platformops` ClusterIP Service → ready Pods. Do not treat a local hosts entry as public DNS or expose the workstation to the internet.
