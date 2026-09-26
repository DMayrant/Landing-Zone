resource "aws_sns_topic" "security_alerts" {
  name = "guardduty-security-alerts"
}

resource "aws_sns_topic_subscription" "security_team_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.security_team_email
}
