output "organization_id" {
  description = "AWS Organization ID"
  value       = aws_organizations_organization.main.id
}

output "organization_arn" {
  description = "AWS Organization ARN"
  value       = aws_organizations_organization.main.arn
}

output "organization_root_id" {
  description = "Root ID of the AWS Organization"
  value       = aws_organizations_organization.main.roots[0].id
}

output "security_ou_id" {
  description = "Security OU ID"
  value       = aws_organizations_organizational_unit.security.id
}

output "infrastructure_ou_id" {
  description = "Infrastructure OU ID"
  value       = aws_organizations_organizational_unit.infrastructure.id
}

output "workloads_ou_id" {
  description = "Workloads OU ID"
  value       = aws_organizations_organizational_unit.workloads.id
}

output "production_ou_id" {
  description = "Production OU ID"
  value       = aws_organizations_organizational_unit.production.id
}

output "nonproduction_ou_id" {
  description = "NonProduction OU ID"
  value       = aws_organizations_organizational_unit.nonproduction.id
}

output "protect_member_accounts_scp_id" {
  description = "ID of the member-account protection SCP"
  value       = aws_organizations_policy.protect_member_accounts.id
}