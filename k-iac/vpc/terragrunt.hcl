# Terragrunt Configuration for VPC
# Using Terraform AWS Module: terraform-aws-modules/vpc/aws

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.19.0"
}

# Include settings from the root terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name = "k-main-vpc"
  cidr = "10.10.0.0/16"

  # Three Availability Zones in us-east-1
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Define Subnet Ranges
  public_subnets   = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnets  = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  database_subnets = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]

  # Create Database Subnet Group
  create_database_subnet_group = true

  # NAT Gateway Configuration (One per AZ)
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # DNS Hostnames and Support
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Standard Tags
  tags = {
    Terraform   = "true"
    Environment = "production"
    ManagedBy   = "Terragrunt"
  }
}
