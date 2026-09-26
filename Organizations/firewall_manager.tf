resource "aws_fms_admin_account" "main" {
  account_id = aws_organizations_account.security.id
}