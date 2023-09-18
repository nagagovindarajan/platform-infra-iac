resource "aws_cognito_user_pool" "main" {
    name = "platform_user_pool"
}
  

resource "aws_cognito_user_pool_client" "client" {
  name         = "platform_user_pool_client"
  user_pool_id = aws_cognito_user_pool.main.id
  generate_secret = true

  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["openid"]
  supported_identity_providers = ["COGNITO"]

  callback_urls = ["https://platform.apps.nagarajan.cloud/oauth2/idpresponse"]

}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "platform"
  user_pool_id = aws_cognito_user_pool.main.id
}