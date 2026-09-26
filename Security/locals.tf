# locals.tf
locals {
  common_tags = {
    Project     = "aws-landing-zone"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}