resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "guardduty-findings-to-bedrock"
  description = "Send GuardDuty findings to the security analysis Lambda"

  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "bedrock_analyzer" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "bedrock-security-analyzer"
  arn       = aws_lambda_function.bedrock_analyzer.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowGuardDutyEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bedrock_analyzer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_findings.arn
}