#####################################
# CloudTrail S3 Bucket
#####################################

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "landing-zone-cloudtrail-${data.aws_caller_identity.current.account_id}-"

  tags = merge(local.common_tags, {
    Name = "cloudtrail-organization-logs"
  })
}

#####################################
# Versioning
#####################################

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

#####################################
# Server-Side Encryption
#####################################

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#####################################
# Block Public Access
#####################################

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

#####################################
# CloudTrail S3 Bucket Policy
#####################################

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      #####################################
      # Allow CloudTrail to check bucket ACL
      #####################################
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/landing-zone-organization-trail"
          }
        }
      },

      #####################################
      # Management Account CloudTrail Logs
      #####################################
      {
        Sid    = "AWSCloudTrailWriteManagementAccount"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/landing-zone-organization-trail"
          }
        }
      },

      #####################################
      # Organization CloudTrail Logs
      #####################################
      {
        Sid    = "AWSCloudTrailWriteOrganization"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${var.organization_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/landing-zone-organization-trail"
          }
        }
      }
    ]
  })
}