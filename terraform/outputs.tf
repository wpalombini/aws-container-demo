# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_name" {
  value = aws_ecr_repository.container-demo-ecr.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.container-demo-ecr.repository_url
}

output "alb_security_group_id" {
  value = aws_security_group.container-demo-alb-sg.id
}

output "ecs_tasks_security_group_id" {
  value = aws_security_group.container-demo-containers-sg.id
}

output "public_subnet_id_a" {
  value = module.vpc.public_subnet_id_a
}

output "public_subnet_id_b" {
  value = module.vpc.public_subnet_id_b
}

output "alb_dns_name" {
  value       = aws_lb.container-demo-alb.dns_name
  description = "The DNS name of the load balancer"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.container-demo-ecs-cluster.name
  description = "Name of the ECS cluster"
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.container-demo-ecs-cluster.arn
  description = "ARN of the ECS cluster"
}
