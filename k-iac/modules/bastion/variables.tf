variable "vpc_id" {
  type        = string
  description = "VPC ID where the bastion will be created"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID for the bastion host"
}

variable "ssh_allowed_ips" {
  type        = string
  description = "Comma-separated CIDR blocks for SSH access (e.g. 1.2.3.4/32,5.6.7.8/32)"
}
