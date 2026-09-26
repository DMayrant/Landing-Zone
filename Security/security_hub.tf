# security_hub.tf

resource "aws_securityhub_account" "us_east_1" {
  enable_default_standards = true
  auto_enable_controls     = true
}

resource "aws_securityhub_account" "eu_west_2" {
  provider = aws.euro

  enable_default_standards = true
  auto_enable_controls     = true
}

# View findings from both regions in us-east-1.
resource "aws_securityhub_finding_aggregator" "us_east_1" {
  linking_mode      = "SPECIFIED_REGIONS"
  specified_regions = ["eu-west-2"]

  depends_on = [
    aws_securityhub_account.us_east_1,
    aws_securityhub_account.eu_west_2
  ]
}