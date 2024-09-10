terraform {
  backend "s3" {
    bucket = "postgres-terraform-state"
    key    = "us-east-1/production/resources/rds/terraform.tfstate"
    region = "us-east-1"
  }
}