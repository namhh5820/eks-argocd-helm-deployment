# Terragrunt Configuration for EKS Cluster
# Using Terraform AWS Module: terraform-aws-modules/eks/aws

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.31.0"
}

# Include settings from the root terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

# Dependency on the VPC module to get VPC ID and Private Subnets
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name    = "k-eks-cluster"
  cluster_version = "1.31"

  # Networking
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

  # EKS Private Mode
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  # EKS Add-ons
  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Managed Node Group Configuration
  eks_managed_node_groups = {
    k-app-ng = {
      name = "k-app-ng"

      instance_types = ["m4.xlarge"]
      
      min_size     = 2
      max_size     = 5
      desired_size = 2

      subnet_ids = dependency.vpc.outputs.private_subnets

      # Ensure nodes are in private subnets
      labels = {
        Environment = "production"
        GithubRepo  = "eks-argocd-helm-deployment"
      }
    }
  }

  # Authentication
  enable_cluster_creator_admin_permissions = true

  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}
