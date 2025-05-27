# DevOps Assignment - EKS Deployment with CI/CD

## Prerequisites

```bash
# Install required tools
aws --version
terraform --version
kubectl version --client
docker --version
helm version
```

## Initial Setup

### 1. Create S3 Bucket for Terraform State

```bash
# Make script executable
chmod +x create_s3_bucket.sh

# Create bucket (replace with your unique bucket name)
./create-s3-bucket.sh your-terraform-state-bucket-name us-west-2
```

### 2. Validate Terraform Backend

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket-name"
    key    = "terraform/state"
    region = "us-west-2"
  }
}
```

### 3. Setup GitHub Secrets

Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Manual Deployment

### Deploy Infrastructure

```bash
# 1. Clone and navigate
https://github.com/kuzishai/devops-task.git
cd devops-task/terraform

# 2. Configure variables
# Edit terraform.tfvars with your values

# 3. Initialize and deploy
terraform init
terraform validate
terraform plan
terraform apply

# 4. Configure kubectl
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_id)
```

### Deploy Applications Manually

```bash
# Navigate to k8s directory
cd ../k8s

# Deploy applications
kubectl apply -f backend/
kubectl apply -f frontend/

# Wait for LoadBalancers
kubectl get services --all-namespaces -w
```

## CI/CD Deployment

### GitHub Actions Workflow

The CI/CD pipeline (`.github/workflows/deploy.yml`) automatically:

1. **Gets Terraform Outputs** - Retrieves ECR repository URLs and cluster info
2. **Builds Images** - Creates Docker images for backend and frontend
3. **Pushes to ECR** - Uploads images to AWS Container Registry
4. **Deploys to EKS** - Updates Kubernetes deployments with new images

### Trigger Deployment

```bash
# Push to main branch triggers deployment
git add .
git commit -m "Deploy application"
git push origin main
```

## Project Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline
├── terraform/
│   ├── modules/
│   │   ├── ecr/                # ECR repositories
│   │   ├── vpc/                # VPC configuration
│   │   ├── security/           # IAM roles and security groups
│   │   └── eks/                # EKS cluster
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── backend.tf              # S3 backend configuration
├── k8s/
│   ├── backend-deployment.yaml # Backend K8s manifests
│   ├── frontend-deployment.yaml# Frontend K8s manifests
│   └── ingress.yaml            # Ingress configuration
├── backend-app/
│   └── Dockerfile              # Backend container
├── frontend/
│   └── Dockerfile              # Frontend container
├── create-s3-bucket.sh         # S3 bucket creation script
└── README.md
```

## Access Applications

```bash
# Get service URLs
echo "Frontend: http://$(kubectl get service frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Backend: http://$(kubectl get service backend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8080"
echo "Grafana: http://$(kubectl get service grafana-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):3000"
```

## Monitoring

Access monitoring tools:
- **Prometheus**: Available through port-forward or LoadBalancer
- **Grafana**: Default credentials `admin/admin123` (configurable in terraform.tfvars)

```bash
# Port-forward for local access
kubectl port-forward -n monitoring service/grafana-service 3000:3000
kubectl port-forward -n monitoring service/prometheus-service 9090:9090
```

## Cleanup

```bash
# Destroy infrastructure
terraform destroy

# Delete S3 bucket (if needed)
aws s3 rb s3://your-terraform-state-bucket-name --force
```

## Troubleshooting

### Common Issues

1. **ECR Authentication**: Ensure AWS credentials are configured
2. **Kubectl Access**: Run `aws eks update-kubeconfig` after cluster creation
3. **Image Pull Errors**: Verify ECR repository URLs in deployments
4. **LoadBalancer Pending**: Check AWS Load Balancer Controller installation

### Debug Commands

```bash
# Check pod status
kubectl get pods --all-namespaces

# View pod logs
kubectl logs -f deployment/backend-app
kubectl logs -f deployment/frontend-app

# Describe resources
kubectl describe service frontend-service
```