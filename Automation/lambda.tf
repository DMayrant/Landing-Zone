############################
# Package Lambda Python Code
############################

data "archive_file" "bedrock_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/bedrock_finding.py"
  output_path = "${path.module}/bedrock_call.zip"
}


####################
# Lambda Function
####################

resource "aws_lambda_function" "bedrock_analyzer" {
  function_name = "bedrock-security-analyzer"

  filename         = data.archive_file.bedrock_lambda_zip.output_path
  source_code_hash = data.archive_file.bedrock_lambda_zip.output_base64sha256

  role = aws_iam_role.bedrock_lambda_role.arn

  runtime = "python3.12"
  handler = "bedrock_findings.lambda_handler"

  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      BEDROCK_MODEL_ID = "nvidia.nemotron-nano-12b-v2"
      AWS_REGION_NAME  = "us-east-1"
    }
  }
}


#######################
# CloudWatch Log Group
#######################

resource "aws_cloudwatch_log_group" "bedrock_lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.bedrock_analyzer.function_name}"

  retention_in_days = 7
}