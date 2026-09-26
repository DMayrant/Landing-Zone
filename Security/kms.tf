# kms.tf

data "aws_caller_identity" "current" {}

locals {
  kms_admin_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableAccountIAMPolicies"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_key" "us_east_1" {
  description             = "Landing zone security key in us-east-1"
  policy                  = local.kms_admin_policy
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(local.common_tags, {
    Name = "landing-zone-security-us-east-1"
  })
}

resource "aws_kms_alias" "us_east_1" {
  name          = "alias/landing-zone-security-us-east-1"
  target_key_id = aws_kms_key.us_east_1.key_id
}

resource "aws_kms_key" "eu_west_2" {
  provider = aws.euro

  description             = "Landing zone security key in eu-west-2"
  policy                  = local.kms_admin_policy
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(local.common_tags, {
    Name = "landing-zone-security-eu-west-2"
  })
}

resource "aws_kms_alias" "eu_west_2" {
  provider = aws.euro

  name          = "alias/landing-zone-security-eu-west-2"
  target_key_id = aws_kms_key.eu_west_2.key_id
}