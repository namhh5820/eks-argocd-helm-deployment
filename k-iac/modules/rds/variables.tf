variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block for security group rules"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Database subnet group name"
}
