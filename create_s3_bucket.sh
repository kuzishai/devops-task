#!/bin/bash

# S3 Bucket Creation Script for Terraform Backend
# Usage: ./create-s3-bucket.sh [bucket-name] [region]

set -e

# Default values
DEFAULT_REGION="us-west-2"
BUCKET_NAME="${1:-your-terraform-state-bucket-name}"
REGION="${2:-$DEFAULT_REGION}"

echo "Creating S3 bucket: $BUCKET_NAME in region: $REGION"

# Create S3 bucket
if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION"
fi

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "S3 bucket $BUCKET_NAME created successfully with:"
echo "  - Versioning enabled"
echo "  - Server-side encryption enabled"
echo "  - Public access blocked"
echo ""
echo "Update your Terraform backend configuration:"
echo "  bucket = \"$BUCKET_NAME\""
echo "  region = \"$REGION\""