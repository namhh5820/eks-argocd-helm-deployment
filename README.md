# EKS ArgoCD Helm Deployment

This project contains:
- `python-app/`: A simple Flask application.
- `nodejs-app/`: A simple Node.js Express application.
- `k-helm-charts/`: Helm charts for both Python and Node.js apps.
- `k-platform-deploy/`: ArgoCD Application manifests and environment-specific values.
- `k-iac/`: Infrastructure as Code (IaC) using Terragrunt/Terraform.
- `.github/workflows/`: GitHub Action CI/CD pipelines.

## 🚀 CI/CD Workflows (GitHub Actions)

We have implemented automated CI pipelines for both applications:
- **Location:** `.github/workflows/nodejs-ci.yml` and `.github/workflows/python-ci.yml`
- **Authentication:** AWS OIDC connection assuming the `Terraform-SSO` role.
- **Build & Push:** Builds Docker images and pushes to Amazon ECR.
- **Tagging:** Uses `branch-commit-id` format.
- **GitOps:** Automatically updates `image.tag` in `k-platform-deploy/argocd-app-*/environments/prod/values.yaml` and commits back to the repo.
- **Notifications:** Sends status updates to Slack.

**Required Secrets:**
- `AWS_ACCOUNT_ID`: Your AWS Account ID.
- `SLACK_WEBHOOK_URL`: Your Slack channel webhook.

## 🏗️ Infrastructure as Code (Terragrunt)

The `k-iac/` folder contains the infrastructure definition using Terragrunt and official AWS modules.

### Components:
1.  **VPC (`k-iac/vpc`):**
    - CIDR: `10.10.0.0/16`
    - 3 AZs with Public, Private, and Database subnets.
    - NAT Gateway enabled in each AZ for high availability.
2.  **EKS Cluster (`k-iac/eks`):**
    - Private mode (API access restricted to VPC/Bastion).
    - Managed Node Group `k-app-ng` (Instance: `m4.xlarge`, Scale: 2-5).
    - Add-ons: VPC CNI and EBS CSI Driver.
3.  **RDS PostgreSQL (`k-iac/rds`):**
    - Primary + 1 Read Replica in database subnets.
    - Random complex password generated and stored in AWS Secrets Manager (`k-rds-prod`).
4.  **Bastion Host (`k-iac/bastion`):**
    - Secure entry point in public subnet.
    - SSH restricted to specific Office/Home IPs.
    - SSH Private Key stored in AWS Secrets Manager (`k-bastion-ssh-key`).

### How to Deploy Infrastructure:
```bash
cd k-iac
terragrunt run-all plan
terragrunt run-all apply
```

### Accessing the Cluster:
A helper script is provided to assume the necessary role and configure `kubectl`:
```bash
cd k-iac/eks
./k-eks-access-prod.sh
```

## 🛠️ ArgoCD Deployment

### 1. Update Repo URLs
Before pushing, search and replace `<your-username>` in `k-platform-deploy/**/*.yaml` with your actual GitHub username.

### 2. Deploy Karpenter and Apps
Ensure your `kubectl` is pointed to your EKS cluster.

```bash
# Deploy Karpenter Controller & Resources
kubectl apply -f k-platform-deploy/argocd-app-karpenter.yaml
kubectl apply -f k-platform-deploy/argocd-app-karpenter-resources.yaml

# Deploy Apps via ArgoCD
kubectl apply -f k-platform-deploy/argocd-app-python/apps/prod.yaml
kubectl apply -f k-platform-deploy/argocd-app-nodejs/apps/prod.yaml
```

ArgoCD will automatically fetch the Helm charts from `k-helm-charts` and apply the environment-specific values from `k-platform-deploy`.
