# EKS ArgoCD Helm Deployment

This project contains:
- `python-app/`: A simple Flask application.
- `nodejs-app/`: A simple Node.js Express application.
- `k-helm-charts/`: Helm charts for both Python and Node.js apps.
- `k-platform-deploy/`: ArgoCD Application manifests and environment-specific values.
    - `argocd-app-python/`: Python deployment manifests and values.
    - `argocd-app-nodejs/`: Node.js deployment manifests and values.

## Instructions

### 1. Push to GitHub

Create two repositories on GitHub: `k-helm-charts` and `k-platform-deploy`.

```bash
# Push Helm Charts
cd k-helm-charts
git add .
git commit -m "update helm charts"
git remote add origin https://github.com/<your-username>/k-helm-charts.git
git branch -M main
git push -u origin main

# Push Platform Deployment manifests
cd ../k-platform-deploy
git add .
git commit -m "restructure platform deploy"
git remote add origin https://github.com/<your-username>/k-platform-deploy.git
git branch -M main
git push -u origin main
```

### 2. Update Repo URLs

Before pushing, search and replace `<your-username>` in `k-platform-deploy/**/apps/*.yaml` with your actual GitHub username.

### 3. Deploy to EKS using ArgoCD

Ensure your `kubectl` is pointed to your EKS cluster. Then, apply the ArgoCD applications:

```bash
# Python App
kubectl apply -f k-platform-deploy/argocd-app-python/apps/qa.yaml
kubectl apply -f k-platform-deploy/argocd-app-python/apps/stag.yaml
kubectl apply -f k-platform-deploy/argocd-app-python/apps/prod.yaml

# Node.js App
kubectl apply -f k-platform-deploy/argocd-app-nodejs/apps/qa.yaml
kubectl apply -f k-platform-deploy/argocd-app-nodejs/apps/stag.yaml
kubectl apply -f k-platform-deploy/argocd-app-nodejs/apps/prod.yaml
```

ArgoCD will automatically:
1. Fetch the Helm chart from `k-helm-charts`.
2. Apply the values from the raw GitHub URLs in `k-platform-deploy`.
3. Create the namespaces and deploy the app to EKS.

### 4. Docker Images

Build and push your Docker images:

```bash
# Python App
cd python-app
docker build -t <your-image-repository>/python-app:latest .
docker push <your-image-repository>/python-app:latest

# Node.js App
cd ../nodejs-app
docker build -t <your-image-repository>/nodejs-app:latest .
docker push <your-image-repository>/nodejs-app:latest
```

Update `k-helm-charts/*/values.yaml` with the actual `<your-image-repository>`.
