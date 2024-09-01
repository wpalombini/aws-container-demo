# ECS Cluster
resource "aws_ecs_cluster" "container-demo-ecs-cluster" {
  name = "container-demo-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "container-demo-cluster"
  }
}

# ECS Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "container-demo-ecs-cluster-cp" {
  cluster_name = aws_ecs_cluster.container-demo-ecs-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "container-demo-task-definition" {
  family                   = "container-demo-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "container-demo-app"
      image     = "${aws_ecr_repository.container-demo-ecr.repository_url}:1"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/container-demo"
          awslogs-region        = "ap-southeast-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "container-demo-task"
  }
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary policies to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch log group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/container-demo"
  retention_in_days = 30
}

# ECS Service
resource "aws_ecs_service" "container-demo-ecs-service" {
  name            = "container-demo-service"
  cluster         = aws_ecs_cluster.container-demo-ecs-cluster.id
  task_definition = aws_ecs_task_definition.container-demo-task-definition.arn
  desired_count   = 2 # Running two tasks for high availability
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [module.vpc.public_subnet_id_a, module.vpc.public_subnet_id_b]
    security_groups  = [aws_security_group.container-demo-containers-sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.container-demo-tg.arn
    container_name   = "container-demo-app"
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.container-demo-ecs-cluster.name}/${aws_ecs_service.container-demo-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy (scale up)
resource "aws_appautoscaling_policy" "ecs_policy_scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# Auto Scaling Policy (scale down)
resource "aws_appautoscaling_policy" "ecs_policy_scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# CloudWatch Alarm (high CPU utilization)
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ecs cpu utilization"
  alarm_actions       = [aws_appautoscaling_policy.ecs_policy_scale_up.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.container-demo-ecs-cluster.name
    ServiceName = aws_ecs_service.container-demo-ecs-service.name
  }
}

# CloudWatch Alarm (low CPU utilization)
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_low" {
  alarm_name          = "ecs-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ecs cpu utilization"
  alarm_actions       = [aws_appautoscaling_policy.ecs_policy_scale_down.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.container-demo-ecs-cluster.name
    ServiceName = aws_ecs_service.container-demo-ecs-service.name
  }
}
