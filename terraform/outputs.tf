output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module"
  value       = module.eks.kubectl_config
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "prometheus_url" {
  description = "Prometheus service URL"
  value       = module.eks.prometheus_url
}

output "grafana_url" {
  description = "Grafana service URL"  
  value       = module.eks.grafana_url
}

output "monitoring_info" {
  description = "Monitoring access information"
  value = {
    prometheus_note = "Prometheus URL will be available in monitoring_urls.txt after deployment"
    grafana_note    = "Grafana URL will be available in monitoring_urls.txt after deployment"
    grafana_credentials = "admin/<password_from_terraform_vars>"
    file_location   = "Check ./monitoring_urls.txt for actual URLs"
  }
}

# ECR Outputs
output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.ecr.backend_repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.ecr.frontend_repository_url
}

output "ecr_backend_repository_name" {
  description = "Name of the backend ECR repository"
  value       = module.ecr.backend_repository_name
}

output "ecr_frontend_repository_name" {
  description = "Name of the frontend ECR repository"
  value       = module.ecr.frontend_repository_name
}