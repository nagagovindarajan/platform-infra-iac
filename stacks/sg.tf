resource "aws_security_group" "lb-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "lb-sg"
  description = "security group for load balancer"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-sg"
  }
}

resource "aws_security_group" "ecs-service-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "ecs-service-sg"
  description = "security group for ecs"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }

  tags = {
    Name = "ecs-service-sg"
  }
}