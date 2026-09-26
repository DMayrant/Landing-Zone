# guardduty.tf

resource "aws_guardduty_detector" "us_east_1" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = merge(local.common_tags, {
    Name = "us-east-1-guardduty"
  })
}

resource "aws_guardduty_detector" "eu_west_2" {
  provider = aws.euro

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = merge(local.common_tags, {
    Name = "eu-west-2-guardduty"
  })
}