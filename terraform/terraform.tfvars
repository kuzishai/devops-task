aws_region      = "us-west-2"
cluster_name    = "demo-eks-cluster"
cluster_version = "1.28"

vpc_cidr = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_max_size       = 4
node_min_size       = 1

# Monitoring Configuration
grafana_admin_password   = "SecurePassword123!"
prometheus_storage_size  = "10Gi"

# Project Configuration
environment    = "dev"
project_name   = "eks-demo"
owner          = "DevOps Team"
cost_center    = "Engineering"