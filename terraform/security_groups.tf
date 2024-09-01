# From Internet to ALB Security Group
resource "aws_security_group" "container-demo-alb-sg" {
  name        = "container-demo-alb-sg"
  description = "Security group for public inbound traffic to container demo ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "container-demo-alb-sg"
  }
}

# From ALB to Containers Security Group
resource "aws_security_group" "container-demo-containers-sg" {
  name        = "container-demo-ecs-tasks"
  description = "Security group for container demo ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow inbound traffic to containers from ALB"
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    security_groups = [aws_security_group.container-demo-alb-sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "container-demo-ecs-tasks"
  }
}
