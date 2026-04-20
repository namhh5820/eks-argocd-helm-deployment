# FluxCD GitOps Deployment

This directory contains the FluxCD configuration for managing the Node.js and Python applications across multiple Kubernetes clusters using a GitOps approach.

## 🏗️ Architecture: Multi-Cluster Base/Overlay

We use a hierarchical structure to maintain clean, DRY (Don't Repeat Yourself) configurations:

- **`base/`**: Contains the core `HelmRelease` definitions and Git sources shared by all environments.
- **`overlays/`**: Environment-specific patches (Prod, QA, Staging) that override replicas, environment variables, and names.
- **`clusters/`**: The entry point for each physical cluster. Each cluster points to its respective overlay.

---

## 🚀 Deployment Steps

### 1. Prerequisites
- [Flux CLI](https://fluxcd.io/flux/installation/) installed locally.
- A Kubernetes cluster for each environment (QA, Staging, Prod).
- `kubectl` context set to the target cluster.

### 2. Initial Bootstrap (Source)
Before deploying applications, Flux needs to know where to find the source code. On **each** cluster, run:

```bash
# Apply the GitRepository source
kubectl apply -f fluxcd/base/sources/main-repo.yaml
```

*Note: Ensure you update the `url` in `fluxcd/base/sources/main-repo.yaml` to point to your actual repository.*

### 3. Deploy to a Specific Cluster

Execute the following commands based on which cluster you are currently connected to:

#### **Production Cluster**
```bash
kubectl apply -f fluxcd/clusters/prod-cluster/cluster-sync.yaml
```

#### **Staging Cluster**
```bash
kubectl apply -f fluxcd/clusters/stag-cluster/cluster-sync.yaml
```

#### **QA Cluster**
```bash
kubectl apply -f fluxcd/clusters/qa-cluster/cluster-sync.yaml
```

---

## 🔍 Monitoring and Validation

After applying the `cluster-sync.yaml`, you can monitor the progress with these commands:

```bash
# Check the status of the Kustomization sync
flux get kustomizations

# Check the status of the Helm releases
flux get helmreleases -A

# View logs for a specific sync
flux logs --level=info
```

## 🛠️ Modifying Configurations

1.  **To change a global setting**: Modify files in `fluxcd/base/`.
2.  **To change an environment-specific setting**: Modify the `patches` in `fluxcd/overlays/<env>/kustomization.yaml`.
3.  **To add a new cluster**: Create a new folder in `fluxcd/clusters/` and point it to the desired overlay.
