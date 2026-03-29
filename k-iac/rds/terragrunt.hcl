# Terragrunt Configuration for RDS PostgreSQL

terraform {
  source = "../modules/rds"
}

# Include settings from the root terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

# Dependency on the VPC module to get VPC ID and Database Subnet Group
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  vpc_cidr             = "10.10.0.0/16" # Match your VPC range
  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
}
