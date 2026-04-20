# FluxCD GitOps Deployment

This directory contains the FluxCD configuration for managing the Node.js and Python applications in a single-cluster environment.

## 📁 Structure

- **`sources/`**: Defines the GitRepository source pointing to this repo.
- **`apps/`**: Contains the HelmRelease definitions for the Node.js and Python applications.
- **`kustomization.yaml`**: Aggregates all manifests for easy application.
- **`cluster-sync.yaml`**: The Flux Kustomization that manages the synchronization of this directory.

---

## 🚀 Deployment Steps

### 1. Prerequisites
- [Flux CLI](https://fluxcd.io/flux/installation/) installed locally.
- Access to a Kubernetes cluster.

### 2. Initial Setup
On your cluster, apply the source and the sync manifest:

```bash
# 1. Apply the GitRepository source
kubectl apply -f fluxcd/sources/main-repo.yaml

# 2. Apply the Cluster Sync (this will deploy the apps)
kubectl apply -f fluxcd/cluster-sync.yaml
```

*Note: Ensure you update the `url` in `fluxcd/sources/main-repo.yaml` to point to your actual repository.*

---

## 🔍 Monitoring

Monitor the status of your GitOps deployment:

```bash
# Check sync status
flux get kustomizations

# Check application status
flux get helmreleases -A

# View Flux logs
flux logs --level=info
```
