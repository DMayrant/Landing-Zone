# s3.tf

resource "aws_s3_bucket" "config_logs" {
  bucket_prefix = "landing-zone-config-${data.aws_caller_identity.current.account_id}-"

  tags = merge(local.common_tags, {
    Name = "aws-config-delivery"
  })
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AWSConfigBucketCheck"
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action = [
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.config_logs.arn

        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"

        Principal = {
          Service = "config.amazonaws.com"
        }

        Action = "s3:PutObject"

        # Allows the regional prefixes configured in config.tf:
        # us-east-1/AWSLogs/<account-id>/Config/*
        # eu-west-2/AWSLogs/<account-id>/Config/*
        Resource = "${aws_s3_bucket.config_logs.arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"

        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
