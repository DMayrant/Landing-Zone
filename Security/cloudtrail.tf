# cloudtrail.tf

resource "aws_cloudtrail" "organization" {
  name = "landing-zone-organization-trail"

  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  # Capture activity across the AWS Organization
  is_organization_trail = true

  # Protect log integrity
  enable_log_file_validation = true

  tags = merge(local.common_tags, {
    Name = "landing-zone-organization-trail"
  })

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs
  ]
}