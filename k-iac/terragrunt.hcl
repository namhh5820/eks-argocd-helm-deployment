# Root Terragrunt Configuration
# Handles Remote State and Provider Configuration

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "k-terragrunt-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1" # Update with your region
    encrypt        = true
    dynamodb_table = "k-terragrunt-lock-table" # Highly recommended for state locking
  }
}

# Generate AWS Provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  # assume_role {
  #   role_arn = "arn:aws:iam::<your-account-id>:role/Terraform-SSO"
  # }
}
EOF
}
