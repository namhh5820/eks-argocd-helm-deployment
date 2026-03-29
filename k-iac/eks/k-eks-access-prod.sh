#!/bin/bash

# Configuration
CLUSTER_NAME="k-eks-cluster-prod"
REGION="us-east-1"
ROLE_NAME="Terraform-SSO"

# 1. Get AWS Account ID (Dynamically if logged in, or provide as env var)
if [ -z "$AWS_ACCOUNT_ID" ]; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: Could not determine AWS Account ID. Please ensure you are logged in to AWS CLI."
        exit 1
    fi
fi

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"

echo "Assuming role: $ROLE_ARN..."

# 2. Assume Role and export temporary credentials
CREDENTIALS=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "EKS-Access-Session")

if [ $? -ne 0 ]; then
    echo "Error: Failed to assume role $ROLE_ARN"
    exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')

# 3. Update Kubeconfig
echo "Updating kubeconfig for $CLUSTER_NAME in $REGION..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

# 4. Cluster Summary
echo "================================================================"
echo " CLUSTER STATUS SUMMARY"
echo "================================================================"

echo "--- Nodes ---"
kubectl get nodes -o wide

echo ""
echo "--- Pods (All Namespaces) ---"
kubectl get pods -A --field-selector=status.phase!=Succeeded

echo "================================================================"
