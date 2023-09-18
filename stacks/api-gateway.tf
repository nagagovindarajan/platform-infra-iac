resource "aws_api_gateway_rest_api" "phone_parser_api" {
  name        = "phone_parser_api"
  description = "phone parser API"
  binary_media_types = ["multipart/form-data"]
}

resource "aws_api_gateway_resource" "list_tasks_resource" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  parent_id   = aws_api_gateway_rest_api.phone_parser_api.root_resource_id
  path_part   = "list-tasks"
}

resource "aws_api_gateway_resource" "create_task_resource" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  parent_id   = aws_api_gateway_rest_api.phone_parser_api.root_resource_id
  path_part   = "create-task"
}

resource "aws_api_gateway_resource" "find_task_resource" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  parent_id   = aws_api_gateway_rest_api.phone_parser_api.root_resource_id
  path_part   = "find-task"
}

resource "aws_api_gateway_resource" "delete_task_resource" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  parent_id   = aws_api_gateway_rest_api.phone_parser_api.root_resource_id
  path_part   = "delete-task"
}

resource "aws_api_gateway_method" "parser_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id   = aws_api_gateway_resource.list_tasks_resource.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required  = true
}

resource "aws_api_gateway_method" "find_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id   = aws_api_gateway_resource.find_task_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required  = true
}

resource "aws_api_gateway_method" "parser_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id   = aws_api_gateway_resource.create_task_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required  = true
}

resource "aws_api_gateway_method" "parser_delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id   = aws_api_gateway_resource.delete_task_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
  api_key_required  = true
}

resource "aws_api_gateway_integration" "list_integration" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id = aws_api_gateway_resource.list_tasks_resource.id
  http_method = aws_api_gateway_method.parser_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_tasks_lambda.invoke_arn

  credentials = aws_iam_role.api_gateway_role.arn
}


resource "aws_api_gateway_integration" "find_integration" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id = aws_api_gateway_resource.find_task_resource.id
  http_method = aws_api_gateway_method.find_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fetch_task_by_id_lambda.invoke_arn

  credentials = aws_iam_role.api_gateway_role.arn
}

resource "aws_api_gateway_integration" "create_integration" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id = aws_api_gateway_resource.create_task_resource.id
  http_method = aws_api_gateway_method.parser_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_task_lambda.invoke_arn
  content_handling = "CONVERT_TO_BINARY"  # Enable binary support

  credentials = aws_iam_role.api_gateway_role.arn
}

resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  resource_id = aws_api_gateway_resource.delete_task_resource.id
  http_method = aws_api_gateway_method.parser_delete_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_task_by_id_lambda.invoke_arn
    
  credentials = aws_iam_role.api_gateway_role.arn
}

# Create API Key
resource "aws_api_gateway_api_key" "parser_api_key" {
  name = "parser-api-key"
}

# Associate API Key with GET Method
resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.phone_parser_api.id
  deployment_id = aws_api_gateway_deployment.prod_deployment.id
}

resource "aws_api_gateway_deployment" "prod_deployment" {
  depends_on  = [aws_api_gateway_integration.list_integration, aws_api_gateway_integration.find_integration, aws_api_gateway_integration.create_integration, aws_api_gateway_integration.delete_integration]
  rest_api_id = aws_api_gateway_rest_api.phone_parser_api.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(
      jsonencode(
        [
          aws_api_gateway_method.parser_get_method,
          aws_api_gateway_method.find_post_method,
          aws_api_gateway_method.parser_post_method,
          aws_api_gateway_method.parser_delete_method
        ]
      )
    )
  }
}

resource "aws_api_gateway_usage_plan" "parser_usage_plan" {
  name = "parser-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.phone_parser_api.id
    stage  = aws_api_gateway_stage.prod_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "parser_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.parser_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.parser_usage_plan.id
}

output "api_key_value" {
  value = aws_api_gateway_api_key.parser_api_key.value
  sensitive = true
}

resource "aws_api_gateway_domain_name" "naga_api" {
  domain_name = "api.apps.nagarajan.cloud"
  certificate_arn = aws_acm_certificate.app_certificate.arn
}

resource "aws_api_gateway_base_path_mapping" "naga_api_mapping" {
  api_id      = aws_api_gateway_rest_api.phone_parser_api.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  domain_name = aws_api_gateway_domain_name.naga_api.domain_name
}