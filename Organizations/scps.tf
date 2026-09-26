# scp.tf

resource "aws_organizations_policy" "protect_member_accounts" {
  name        = "ProtectMemberAccounts"
  description = "Prevent member accounts from leaving the organization or closing, restrict ap-south-1 and ap-south-2"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeavingOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
      {
        Sid      = "DenyClosingAccount"
        Effect   = "Deny"
        Action   = "account:CloseAccount"
        Resource = "*"
      },
      {
        Sid      = "DenySpecifiedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"

        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = [
              "ap-south-1",
              "ap-south-2"
            ]
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "ProtectMemberAccounts"
  })
}

resource "aws_organizations_policy_attachment" "protect_member_accounts_root" {
  policy_id = aws_organizations_policy.protect_member_accounts.id
  target_id = aws_organizations_organization.main.roots[0].id
}