# ECR repository URL (used by GitHub Actions to push image)
output "ecr_repository_url" {
  description = "URL of the ECR repository for Docker pushes"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}