# Terragrunt Configuration for Bastion Host

terraform {
  source = "../modules/bastion"
}

# Include settings from the root terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

# Dependency on the VPC module
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id           = dependency.vpc.outputs.vpc_id
  public_subnet_id = dependency.vpc.outputs.public_subnets[0] # Put in the first public subnet
  
  # Allowing SSH from office and home IPs
  ssh_allowed_ips  = "172.16.0.2/32,172.16.0.10/32"
}
