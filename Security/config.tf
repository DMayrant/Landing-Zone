# config.tf

data "aws_iam_policy_document" "config_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = "landing-zone-aws-config-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume_role.json

  tags = merge(local.common_tags, {
    Name = "landing-zone-aws-config-role"
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "us_east_1" {
  name     = "landing-zone-config-us-east-1"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_iam_role_policy_attachment.config]
}

resource "aws_config_delivery_channel" "us_east_1" {
  name           = "landing-zone-config-us-east-1"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
  s3_key_prefix  = "us-east-1"

  depends_on = [aws_config_configuration_recorder.us_east_1]
}

resource "aws_config_configuration_recorder_status" "us_east_1" {
  name       = aws_config_configuration_recorder.us_east_1.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us_east_1]
}

resource "aws_config_configuration_recorder" "eu_west_2" {
  provider = aws.euro

  name     = "landing-zone-config-eu-west-2"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  depends_on = [aws_iam_role_policy_attachment.config]
}

resource "aws_config_delivery_channel" "eu_west_2" {
  provider = aws.euro

  name           = "landing-zone-config-eu-west-2"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
  s3_key_prefix  = "eu-west-2"

  depends_on = [aws_config_configuration_recorder.eu_west_2]
}

resource "aws_config_configuration_recorder_status" "eu_west_2" {
  provider = aws.euro

  name       = aws_config_configuration_recorder.eu_west_2.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu_west_2]
}