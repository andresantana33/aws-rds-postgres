
variable "organization" {
  type        = string
  description = "Name of the client organization"
  default     = "infra-labs"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "default"
}

################################################################################
# RDS
################################################################################
variable "db_config" {
  type = map(any)
}

variable "region" {
  description = "environment region"
  type        = string
}

variable "storage_encrypted" {
  description = "encrypted"
  default     = "true"
}

variable "skip_final_snapshot" {
  description = "Habilitar ou desabilitar o Snapshot"
  default     = true
}

variable "create_db_parameter_group" {
  description = "Criar parameter_group"
  default     = false
}

variable "username_password" {
  description = "manage_master_user_password"
  default     = true
}

variable "create_db_subnet_group" {
  description = "Criar db_subnet_group"
  default     = true
}

variable "port" {
  description = "Porta BD"
  default     = "5432"
  type        = number
}

variable "username" {
  description = "Nome de usuario do banco de dados"
  default     = "postgres"
}

variable "manage_master_user_password_rotation" {
  description = "manage_master_user_password"
  default     = false
}

