# --------------------------------
# Lambda Assume Role
# --------------------------------

resource "aws_iam_role" "bedrock_lambda_role" {
  name = "bedrock-security-analyzer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


# --------------------------------
# Lambda Permissions
# --------------------------------

resource "aws_iam_role_policy" "bedrock_lambda_policy" {
  name = "bedrock-security-analyzer-policy"
  role = aws_iam_role.bedrock_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # CloudWatch Logs
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:*:*:*"
      },

      # Amazon Bedrock
      {
        Effect = "Allow"

        Action = [
          "bedrock:InvokeModel"
        ]

        Resource = "arn:aws:bedrock:us-east-1::foundation-model/nvidia.nemotron-nano-12b-v2"
      }
    ]
  })
}

###########
# SNS 
###########

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish"
  role = aws_iam_role.bedrock_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}