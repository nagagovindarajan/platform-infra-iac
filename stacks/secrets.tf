resource "aws_secretsmanager_secret" "my_aws_access_key" {
  name = "my_aws_access_key"
}

resource "aws_secretsmanager_secret" "my_aws_access_key_id" {
  name = "my_aws_access_key_id"
}
