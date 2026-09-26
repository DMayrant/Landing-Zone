# AWS Landing Zone 🛬

An AWS Landing Zone provides a centralized foundation for security, governance, networking, and account management across multiple AWS accounts. By using controls like Service Control Policies, centralized logging, and standardized networking, I can give teams a secure environment to deploy workloads without rebuilding those controls every time. From a business perspective, that reduces operational overhead, improves compliance, and makes cloud migrations easier to scale.

# Backend Bucket 🪣
```bash
aws s3api create-bucket \
  --bucket dmayrant-landing-zone-tfstate-2026 \
  --region us-east-1
  
aws s3api head-bucket \
  --bucket dmayrant-landing-zone-tfstate-2026
```  

# Terraform 🏗️
```bash
terraform init
terraform fmt -recusive
terraform validate
terraform plan
terraform apply
```