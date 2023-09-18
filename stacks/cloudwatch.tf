resource "aws_cloudwatch_log_group" "platform_eng" {
  name              = "platform-eng-log"
  retention_in_days = 7
}