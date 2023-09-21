resource "aws_ecs_task_definition" "platform_eng_task" {
  family                = "platform-eng-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      "name"         : "platform-eng",
      "image"        : "public.ecr.aws/o7a2v6t3/platform_eng:15",
      "environment": [
        {
          "name": "AWS_DEFAULT_REGION",
          "value": "ap-southeast-1"
        },
        {
          "name": "ENV",
          "value": "prod"
        }
      ],
      secrets = [
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = aws_secretsmanager_secret.my_aws_access_key_id.arn
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = aws_secretsmanager_secret.my_aws_access_key.arn
        }
      ],
      "portMappings" : [
        {
          "containerPort" : 8443,
          "hostPort"      : 8443,
          "protocol"      : "tcp"
        }
      ],
      "healthCheck"  : {
        "command"     : ["CMD-SHELL", "curl -f http://localhost:8443/health || exit 1"],
        "interval"    : 30,
        "timeout"     : 5,
        "retries"     : 3
      },
      "essential"    : true,
      "logConfiguration" : {
        "logDriver"  : "awslogs",
        "options" : {
          "awslogs-group" : "platform-eng-log",
          "awslogs-region" : "ap-southeast-1",
          "awslogs-stream-prefix" : "platform-eng"
        }
      }
    }
  ])
}