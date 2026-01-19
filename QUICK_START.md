# Quick Start Guide

This guide provides quick reference commands for deploying each part of the project.

## Prerequisites Setup

```bash
# Configure AWS CLI
aws configure

# Create key pair
aws ec2 create-key-pair --key-name your-key-pair-name --query 'KeyMaterial' --output text > your-key-pair-name.pem
chmod 400 your-key-pair-name.pem
```

## Part 1: Single EC2 Instance

```bash
cd part1-single-ec2
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your key_name
terraform init
terraform plan
terraform apply
terraform output
```

**Test:**
```bash
# Get IP from terraform output
FLASK_IP=$(terraform output -raw instance_public_ip)
curl http://$FLASK_IP:5000
curl http://$FLASK_IP:3000
```

**Cleanup:**
```bash
terraform destroy
```

## Part 2: Separate EC2 Instances

```bash
cd part2-separate-ec2
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your key_name
terraform init
terraform plan
terraform apply
terraform output
```

**Test:**
```bash
FLASK_IP=$(terraform output -raw flask_instance_public_ip)
EXPRESS_IP=$(terraform output -raw express_instance_public_ip)
curl http://$FLASK_IP:5000
curl http://$EXPRESS_IP:3000
curl http://$EXPRESS_IP:3000/api/data
```

**Cleanup:**
```bash
terraform destroy
```

## Part 3: Docker with ECS/ECR/ALB

### Step 1: Create Infrastructure

```bash
cd part3-docker-ecs
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

### Step 2: Build and Push Docker Images

**Linux/Mac:**
```bash
chmod +x build-and-push.sh
./build-and-push.sh us-east-1
```

**Windows (PowerShell):**
```powershell
.\build-and-push.ps1 -AwsRegion us-east-1
```

**Or manually:**
```bash
# Get repository URLs
FLASK_REPO=$(terraform output -raw ecr_flask_repository_url)
EXPRESS_REPO=$(terraform output -raw ecr_express_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $FLASK_REPO

# Build and push Flask
cd ../flask-app
docker build -t $FLASK_REPO:latest .
docker push $FLASK_REPO:latest

# Build and push Express
cd ../express-app
docker build -t $EXPRESS_REPO:latest .
docker push $EXPRESS_REPO:latest
```

### Step 3: Wait for Services to Start

```bash
# Check ECS services (wait for tasks to be running)
aws ecs list-services --cluster flask-express-cluster
aws ecs describe-services --cluster flask-express-cluster --services flask-express-flask-service flask-express-express-service
```

### Step 4: Test

```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
curl http://$ALB_DNS/
curl http://$ALB_DNS/health
curl http://$ALB_DNS/api/data
curl http://$ALB_DNS/backend/
```

**Cleanup:**
```bash
terraform destroy
```

## Common Commands

### Check Terraform State

```bash
terraform show
terraform state list
```

### View Outputs

```bash
terraform output
terraform output -json
```

### Refresh State

```bash
terraform refresh
```

### Format Code

```bash
terraform fmt -recursive
```

### Validate Configuration

```bash
terraform validate
```

## Troubleshooting Commands

### EC2 (Part 1 & 2)

```bash
# SSH into instance
ssh -i your-key.pem ec2-user@<instance-ip>

# Check services
sudo systemctl status flask-app
sudo systemctl status express-app

# View logs
sudo journalctl -u flask-app -f
sudo journalctl -u express-app -f

# Check ports
sudo netstat -tlnp
```

### ECS (Part 3)

```bash
# Check ECS services
aws ecs describe-services --cluster flask-express-cluster --services flask-express-flask-service

# Check task status
aws ecs list-tasks --cluster flask-express-cluster --service-name flask-express-flask-service

# View CloudWatch logs
aws logs tail /ecs/flask-express-flask --follow

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

### ECR

```bash
# List images
aws ecr list-images --repository-name flask-express-flask
aws ecr describe-images --repository-name flask-express-flask
```
