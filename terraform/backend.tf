terraform {
  backend "s3" {
    # Replace with your actual bucket name and region
    bucket         = "your-terraform-state-bucket-name"
    key            = "eks-demo/terraform.tfstate"
    region         = "us-west-2"

    # Enable state file encryption
    encrypt = true

    # Optional: Use versioning
    versioning = true
  }
}
