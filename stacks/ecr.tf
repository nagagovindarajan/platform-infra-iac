# Alias for AWS provider in us-east-1
# provider "aws" {
#   alias  = "us_east_1"
#   region = "us-east-1"
# }

# resource "aws_ecrpublic_repository" "platform_eng" {
#   provider          = aws.us_east_1
#   repository_name = "platform_eng"
# }

# output "platform_eng-repository-URL" {
#   value = aws_ecrpublic_repository.platform_eng.repository_uri
# }
