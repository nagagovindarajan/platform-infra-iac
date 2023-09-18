resource "aws_ecs_cluster" "fargate_cluster" {
  name = "fargate-cluster"
}

resource "aws_ecs_service" "platform_eng_service" {
  name            = "platform_eng_service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.platform_eng_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.main-private-1.id]
    security_groups = [aws_security_group.ecs-service-sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.platform-target-group.arn
    container_name   = "platform-eng"
    container_port   = 8443
  }

  depends_on = [aws_alb_listener.platform-alb-listener]
}