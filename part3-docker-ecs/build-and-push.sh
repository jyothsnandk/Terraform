#!/bin/bash
# Script to build and push Docker images to ECR
# Usage: ./build-and-push.sh <aws-region>

set -e

AWS_REGION=${1:-us-east-1}
PROJECT_NAME="flask-express"

# Get ECR repository URLs from Terraform output
FLASK_REPO=$(cd .. && terraform -chdir=part3-docker-ecs output -raw ecr_flask_repository_url 2>/dev/null || echo "")
EXPRESS_REPO=$(cd .. && terraform -chdir=part3-docker-ecs output -raw ecr_express_repository_url 2>/dev/null || echo "")

if [ -z "$FLASK_REPO" ] || [ -z "$EXPRESS_REPO" ]; then
    echo "Error: Could not get ECR repository URLs from Terraform output."
    echo "Please run 'terraform apply' in part3-docker-ecs first."
    exit 1
fi

echo "Building and pushing Docker images..."
echo "AWS Region: $AWS_REGION"
echo "Flask Repository: $FLASK_REPO"
echo "Express Repository: $EXPRESS_REPO"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $FLASK_REPO

# Build and push Flask image
echo "Building Flask image..."
cd ../flask-app
docker build -t $FLASK_REPO:latest .
echo "Pushing Flask image..."
docker push $FLASK_REPO:latest

# Build and push Express image
echo "Building Express image..."
cd ../express-app
docker build -t $EXPRESS_REPO:latest .
echo "Pushing Express image..."
docker push $EXPRESS_REPO:latest

echo "Done! Images have been pushed to ECR."
