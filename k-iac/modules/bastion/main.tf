# Local Bastion Module

# 1. Security Group
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "k-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from Office and Home"
      cidr_blocks = var.ssh_allowed_ips
    }
  ]

  egress_rules = ["all-all"]
}

# 2. SSH Key Management
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "k-bastion-key"
  public_key = tls_private_key.this.public_key_openssh
}

# 3. Store in Secret Manager
resource "aws_secretsmanager_secret" "this" {
  name        = "k-bastion-ssh-key"
  description = "Private SSH key for bastion host"
  recovery_window_in_days = 0 # Force delete for testing, change as needed
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = tls_private_key.this.private_key_pem
}

# 4. EC2 Instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "k-bastion-host"

  instance_type          = "t3.micro"
  key_name               = aws_key_pair.this.key_name
  monitoring             = true
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = var.public_subnet_id

  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}
