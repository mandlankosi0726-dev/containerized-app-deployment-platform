# Recovery and restore

The service is stateless: recreate the Pod or cluster and redeploy an immutable image tag. Preserve image provenance/commit metadata and Helm revision history while a cluster remains available. `helm rollback` restores an earlier chart release in that cluster; it does not recover a deleted cluster or image. Keep source, chart values, and release artifact in version control/registry. No user data or persistent volume is present, so there is no application data restore procedure.

If the local Kind cluster fails, inspect Docker and Kind node logs first. Recreating the named development cluster is a destructive operation for that cluster's state; confirm its identity and understand removal before running `scripts/delete-cluster.sh`, then create it and deploy a known immutable tag. Never use the project script against a different cluster context.
