output "backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_registry_id" {
  description = "Registry ID for backend repository"
  value       = aws_ecr_repository.backend.registry_id
}

output "frontend_registry_id" {
  description = "Registry ID for frontend repository"
  value       = aws_ecr_repository.frontend.registry_id
}

output "backend_repository_name" {
  description = "Name of the backend ECR repository"
  value       = aws_ecr_repository.backend.name
}

output "frontend_repository_name" {
  description = "Name of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.name
}