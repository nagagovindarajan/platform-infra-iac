resource "aws_ecrpublic_repository" "platform_eng" {
  provider          = aws.us_east_1
  repository_name = "platform_eng"
}

output "platform_eng-repository-URL" {
  value = aws_ecrpublic_repository.platform_eng.repository_uri
}
