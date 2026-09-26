terraform {
  backend "s3" {
    bucket       = "dmayrant-landing-zone-tfstate-2026"
    key          = "networking/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}