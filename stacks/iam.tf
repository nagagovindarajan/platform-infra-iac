resource "aws_iam_policy" "s3_access_policy" {
  name        = "acm-cert-policy"
  description = "IAM policy for ACM certificate management"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_bucket_policy" { 
  name = "s3_bucket_policy" 
  description = "Policy for S3 access" 
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::german-phonenos",
        "arn:aws:s3:::german-phonenos/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_policy" {
  name = "api-gateway-policy"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_s3_dynamodb_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::german-phonenos/*"]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan"
    ]
    resources = [aws_dynamodb_table.tasks_table.arn]
  }
}

resource "aws_iam_policy" "lambda_s3_dynamodb_policy" {
  name        = "lambda_s3_dynamodb_policy"
  description = "Allows Lambda to access S3 and DynamoDB"
  policy      = data.aws_iam_policy_document.lambda_s3_dynamodb_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_dynamodb_policy.arn
}



resource "aws_iam_policy" "ecs_dynamodb_access" {
  name        = "ecs_dynamodb_access"
  description = "Policy to allow ECS tasks to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role" "ecs-service-role" {
name = "ecs-service-role"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs-service-attach1" {
  name       = "ecs-service-attach1"
  roles      = [aws_iam_role.ecs-service-role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs-service-attach2" {
  policy_arn = aws_iam_policy.s3_bucket_policy.arn 
  role = aws_iam_role.ecs-service-role.name
}

resource "aws_iam_role_policy_attachment" "ecs_service_dynamodb_attach" {
  role       = aws_iam_role.ecs-service-role.name
  policy_arn = aws_iam_policy.ecs_dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_dynamodb_access.arn
}


resource "aws_iam_policy" "ecs_secrets_policy" {
  name        = "ecs_secrets_policy"
  description = "ECS task execution role policy to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_policy.arn
}
