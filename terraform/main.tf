# VPC Module
module "vpc" {
  source = "./modules/vpc"

  cluster_name        = var.cluster_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = data.aws_availability_zones.available.names
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  environment         = var.environment
}

# Security Module
module "security" {
  source = "./modules/security"

  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name            = var.cluster_name
  cluster_version         = var.cluster_version
  subnet_ids             = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  node_subnet_ids        = module.vpc.private_subnet_ids
  cluster_role_arn       = module.security.cluster_role_arn
  node_role_arn          = module.security.node_role_arn
  node_instance_types    = var.node_instance_types
  node_desired_size      = var.node_desired_size
  node_max_size          = var.node_max_size
  node_min_size          = var.node_min_size
  aws_region             = var.aws_region
  vpc_id                 = module.vpc.vpc_id
  grafana_admin_password = var.grafana_admin_password
  prometheus_storage_size = var.prometheus_storage_size
  environment            = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center
}