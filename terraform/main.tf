data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}

locals {
  vpc_name   = "default"
  vpc_id     = "vpc-026d706dad61955c6"
  subnet_ids = ["subnet-07fb304aff8b74abd", "subnet-07fb304aff8b74abd"]
}

data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    "${var.organization}/tier" = "private"
  }
}

################################################################################
# Module - Postgres 
################################################################################
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.5.4"

  for_each = var.db_config

  identifier = each.key

  engine                               = each.value.engine
  engine_version                       = each.value.engine_version
  instance_class                       = each.value.instance_class
  allocated_storage                    = each.value.allocated_storage
  storage_type                         = each.value.storage_type
  performance_insights_enabled         = each.value.performance_insights_enabled
  storage_encrypted                    = var.storage_encrypted
  username                             = var.username
  manage_master_user_password_rotation = var.manage_master_user_password_rotation
  port                                 = var.port
  multi_az                             = each.value.multi_az
  create_db_subnet_group               = var.create_db_subnet_group
  subnet_ids                           = local.subnet_ids
  vpc_security_group_ids               = [module.security_group[each.key].security_group_id]
  apply_immediately                    = false
  max_allocated_storage                = each.value.max_allocated_storage


  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = false

  backup_retention_period   = each.value.backup_retention_period
  skip_final_snapshot       = var.skip_final_snapshot
  deletion_protection       = each.value.deletion_protection
  create_db_parameter_group = var.create_db_parameter_group
}

################################################################################
# Security Group - Postgres 
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  for_each = var.db_config

  name        = "${each.key}-sg"
  description = "Security Group for ${each.key} database"
  vpc_id      = data.aws_vpc.vpc.id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    },
  ]

  #egress
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = "0.0.0.0/0"
  }]
}

#########################
# Password 
#########################

resource "random_password" "password_master" {
  for_each         = var.db_config
  length           = 16
  special          = true
  override_special = "!%&()-_=+[]{}<>:?"
}

###########################
# Secrets Manager
############################

resource "aws_secretsmanager_secret" "sm_master" {
  for_each = var.db_config
  name     = "rds/${each.key}"
}

resource "aws_secretsmanager_secret_version" "master_credentials" {
  for_each      = aws_secretsmanager_secret.sm_master
  secret_id     = each.value.id
  secret_string = jsonencode({ "username" : "postgres", "password" : "${random_password.password_master[each.key].result}" })

}



