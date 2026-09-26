resource "aws_organizations_account" "security" {
  name      = "AWS-Security"
  email     = var.security_account_email
  parent_id = aws_organizations_organizational_unit.security.id
}