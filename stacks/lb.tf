resource "aws_alb" "platform-alb" {
  name               = "platform-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups = [aws_security_group.lb-sg.id]

  tags = {
    Name = "platform-alb"
  }
}

resource "aws_alb_listener" "platform-alb-listener" {
  load_balancer_arn = aws_alb.platform-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type          = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "platform_https_listener" {
  load_balancer_arn = aws_alb.platform-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.app_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.platform-target-group.arn
    order            = 2
  }

}

resource "aws_alb_target_group" "platform-target-group" {
  name        = "platform-target-group"
  port        = 8443
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    path                = "/health"
    matcher             = "200"
  }
}