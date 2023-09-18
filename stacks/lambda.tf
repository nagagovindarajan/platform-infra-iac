data "archive_file" "phone_parser_lambda_package" {  
  type = "zip"  
  source_dir = "${path.module}/lambda-scripts/" 
  output_path = "phone_parser.zip"
}

resource "aws_lambda_function" "create_task_lambda" {
  function_name = "create_task_lambda"
  filename      = "phone_parser.zip"
  source_code_hash = data.archive_file.phone_parser_lambda_package.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "create_task.lambda_handler"
  timeout       = 60
  memory_size   = 128

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_function" "list_tasks_lambda" {
  function_name = "list_tasks_lambda"
  filename      = "phone_parser.zip"
  source_code_hash = data.archive_file.phone_parser_lambda_package.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "list_tasks.lambda_handler"
  timeout       = 60
  memory_size   = 128

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_function" "fetch_task_by_id_lambda" {
  function_name = "fetch_task_by_id_lambda"
  filename      = "phone_parser.zip"
  source_code_hash = data.archive_file.phone_parser_lambda_package.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "fetch_task_by_id.lambda_handler"
  timeout       = 60
  memory_size   = 128
  
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_function" "delete_task_by_id_lambda" {
  function_name = "delete_task_by_id"
  filename      = "phone_parser.zip"
  source_code_hash = data.archive_file.phone_parser_lambda_package.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "delete_task_by_id.lambda_handler"
  timeout       = 60
  memory_size   = 128
  
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_permission" "allow_list" {
  statement_id  = "AllowAPIGatewayInvokeList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_tasks_lambda.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_create" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_task_lambda.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_find" {
  statement_id  = "AllowAPIGatewayInvokeFind"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_task_by_id_lambda.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_delete" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_task_by_id_lambda.arn
  principal     = "apigateway.amazonaws.com"
}