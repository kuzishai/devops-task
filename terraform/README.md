### Deploy Infrastructure

```bash
# 1. navigate
cd devops-task/terraform

# 2. Configure variables
# Edit terraform.tfvars with your values

# 3. Initialize and deploy
terraform init
terraform validate
terraform plan
terraform apply