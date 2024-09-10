terraform {
  backend "s3" {
    bucket = "riverdata-rivia-prod-terraform-state"
    key    = "riverdata/us-east-1/production/resources/rds/terraform.tfstate"
    region = "us-east-1"
  }
}