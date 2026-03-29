# Local RDS Module: PostgreSQL Primary + 1 Read Replica

# 1. Random Password Generation
resource "random_password" "master_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. Store in Secret Manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "k-rds-prod"
  description = "RDS Master Credentials for PostgreSQL"
  recovery_window_in_days = 0 # Set for testing/ease of deletion
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.master_password.result
    engine   = "postgres"
    port     = 5432
    host     = module.db_primary.db_instance_address
  })
}

# 3. Security Group for RDS
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "k-rds-sg"
  description = "PostgreSQL Security Group"
  vpc_id      = var.vpc_id

  # Allow access from VPC (Private Subnets)
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from VPC"
      cidr_blocks = var.vpc_cidr
    }
  ]

  egress_rules = ["all-all"]
}

# 4. RDS Primary Instance
module "db_primary" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = "k-postgres-primary"

  engine               = "postgres"
  engine_version       = "16.3"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "kproddb"
  username = "dbadmin"
  password = random_password.master_password.result
  port     = 5432

  manage_master_user_password = false # Using our random_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7

  skip_final_snapshot = true
  deletion_protection = false # Set to true for actual production

  performance_insights_enabled = true
  create_monitoring_role       = true
  monitoring_interval          = 60

  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}

# 5. RDS Read Replica
module "db_replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = "k-postgres-replica"

  # Source DB for replication
  replicate_source_db = module.db_primary.db_instance_identifier

  engine               = "postgres"
  engine_version       = "16.3"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100

  port = 5432

  # Replicas don't need username/password (they sync from primary)
  # But we must specify they don't manage it
  manage_master_user_password = false

  vpc_security_group_ids = [module.security_group.security_group_id]

  # Replicas don't use subnet groups (they follow the primary)
  # but sometimes need it if in a different AZ/Subnet. 
  # However, replicate_source_db handles most of it.
  
  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "06:00-09:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Terraform   = "true"
    Environment = "production"
    Role        = "Replica"
  }
}
