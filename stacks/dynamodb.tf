resource "aws_dynamodb_table" "platform_eng" {
  name           = "platform-eng"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  tags = {
    Name = "platform-eng"
  }
}