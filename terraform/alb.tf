# Application Load Balancer (ALB) and Target Group for the ECS Fargate service.
resource "aws_lb" "container-demo-alb" {
  name               = "container-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.container-demo-alb-sg.id]
  subnets            = [module.vpc.public_subnet_id_a, module.vpc.public_subnet_id_b]

  enable_deletion_protection = false

  tags = {
    Name = "container-demo-alb"
  }
}

# Target Group for the ECS Fargate service.
resource "aws_lb_target_group" "container-demo-tg" {
  name        = "container-demo-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Listener for the ALB.
resource "aws_lb_listener" "container_demo" {
  load_balancer_arn = aws_lb.container-demo-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.container-demo-tg.arn
  }
}
