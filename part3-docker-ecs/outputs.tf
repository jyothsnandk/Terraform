output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "ecr_flask_repository_url" {
  description = "URL of the Flask ECR repository"
  value       = aws_ecr_repository.flask.repository_url
}

output "ecr_express_repository_url" {
  description = "URL of the Express ECR repository"
  value       = aws_ecr_repository.express.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "flask_service_name" {
  description = "Name of the Flask ECS service"
  value       = aws_ecs_service.flask.name
}

output "express_service_name" {
  description = "Name of the Express ECS service"
  value       = aws_ecs_service.express.name
}

output "flask_url" {
  description = "URL to access Flask backend via ALB"
  value       = "http://${aws_lb.main.dns_name}/backend"
}

output "express_url" {
  description = "URL to access Express frontend via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "docker_push_commands" {
  description = "Commands to build and push Docker images"
  value = <<-EOT
    # Flask Backend
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.flask.repository_url}
    docker build -t ${aws_ecr_repository.flask.repository_url}:latest ../flask-app/
    docker push ${aws_ecr_repository.flask.repository_url}:latest
    
    # Express Frontend
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.express.repository_url}
    docker build -t ${aws_ecr_repository.express.repository_url}:latest ../express-app/
    docker push ${aws_ecr_repository.express.repository_url}:latest
  EOT
}
