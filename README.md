# Flask and Express Deployment on AWS using Terraform

This project demonstrates three different deployment strategies for a Flask backend and Express frontend application on AWS using Terraform:

1. **Part 1**: Deploy both applications on a single EC2 instance
2. **Part 2**: Deploy applications on separate EC2 instances with VPC networking
3. **Part 3**: Deploy applications as Docker containers using ECS, ECR, and ALB

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Part 1: Single EC2 Instance](#part-1-single-ec2-instance)
- [Part 2: Separate EC2 Instances](#part-2-separate-ec2-instances)
- [Part 3: Docker with ECS/ECR/ALB](#part-3-docker-with-ecsecralb)
- [Terraform State Management](#terraform-state-management)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## Prerequisites

Before starting, ensure you have the following installed and configured:

1. **AWS CLI** - [Installation Guide](https://aws.amazon.com/cli/)
2. **Terraform** (>= 1.0) - [Installation Guide](https://www.terraform.io/downloads)
3. **Docker** (for Part 3) - [Installation Guide](https://docs.docker.com/get-docker/)
4. **AWS Account** with appropriate permissions
5. **AWS Key Pair** for EC2 access (create via AWS Console or CLI)

### AWS CLI Configuration

Configure your AWS credentials:

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Default output format (e.g., `json`)

### Create AWS Key Pair

Create a key pair for EC2 access:

```bash
aws ec2 create-key-pair --key-name your-key-pair-name --query 'KeyMaterial' --output text > your-key-pair-name.pem
chmod 400 your-key-pair-name.pem
```

## Project Structure

```
.
├── flask-app/                 # Flask backend application
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── express-app/               # Express frontend application
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── part1-single-ec2/          # Part 1: Single EC2 deployment
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user-data.sh
│   └── terraform.tfvars.example
├── part2-separate-ec2/        # Part 2: Separate EC2 deployment
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user-data-flask.sh
│   ├── user-data-express.sh
│   └── terraform.tfvars.example
├── part3-docker-ecs/          # Part 3: ECS/ECR/ALB deployment
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── build-and-push.sh
│   ├── build-and-push.ps1
│   └── terraform.tfvars.example
├── backend.tf.example         # Example S3 backend configuration
├── .gitignore
└── README.md
```

## Part 1: Single EC2 Instance

Deploy both Flask and Express applications on a single EC2 instance.

### Steps

1. **Navigate to Part 1 directory:**

```bash
cd part1-single-ec2
```

2. **Create terraform.tfvars file:**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `key_name`: Your AWS key pair name
- `aws_region`: Your preferred AWS region (default: us-east-1)

Example:
```hcl
aws_region   = "us-east-1"
instance_type = "t2.micro"
key_name     = "your-key-pair-name"
```

3. **Initialize Terraform:**

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

4. **Review the execution plan:**

```bash
terraform plan
```

This will show you what resources will be created:
- 1 EC2 instance
- 1 Security Group
- AMI data source

5. **Apply the configuration:**

```bash
terraform apply
```

Type `yes` when prompted. This will create:
- EC2 instance with Flask and Express installed
- Security group allowing SSH (22), Flask (5000), and Express (3000) ports

6. **Get the outputs:**

```bash
terraform output
```

You should see:
- `instance_public_ip`: Public IP of the EC2 instance
- `flask_url`: URL to access Flask backend
- `express_url`: URL to access Express frontend

### Verification

1. **Check Flask backend:**

```bash
curl http://<instance_public_ip>:5000
```

Expected response:
```json
{
  "message": "Flask Backend API",
  "status": "running",
  "version": "1.0.0"
}
```

2. **Check Express frontend:**

```bash
curl http://<instance_public_ip>:3000
```

Expected response:
```json
{
  "message": "Express Frontend API",
  "status": "running",
  "version": "1.0.0",
  "backend_url": "http://localhost:5000"
}
```

3. **Check backend health via Express:**

```bash
curl http://<instance_public_ip>:3000/api/backend-health
```

### Screenshots/Commands

Take screenshots of:
- `terraform plan` output
- `terraform apply` output
- `terraform output` showing URLs
- `curl` commands and responses
- AWS Console showing the EC2 instance

## Part 2: Separate EC2 Instances

Deploy Flask and Express on separate EC2 instances with VPC networking.

### Steps

1. **Navigate to Part 2 directory:**

```bash
cd part2-separate-ec2
```

2. **Create terraform.tfvars file:**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region   = "us-east-1"
instance_type = "t2.micro"
key_name     = "your-key-pair-name"
```

3. **Initialize Terraform:**

```bash
terraform init
```

4. **Review the execution plan:**

```bash
terraform plan
```

This will show resources to be created:
- 1 VPC
- 1 Internet Gateway
- 1 Public Subnet
- 1 Route Table
- 2 Security Groups (Flask and Express)
- 2 EC2 Instances (Flask and Express)

5. **Apply the configuration:**

```bash
terraform apply
```

Type `yes` when prompted.

6. **Get the outputs:**

```bash
terraform output
```

You should see:
- `flask_url`: URL to access Flask backend
- `express_url`: URL to access Express frontend
- `flask_instance_public_ip`: Public IP of Flask instance
- `express_instance_public_ip`: Public IP of Express instance

### Verification

1. **Check Flask backend directly:**

```bash
curl http://<flask_instance_public_ip>:5000
```

2. **Check Express frontend:**

```bash
curl http://<express_instance_public_ip>:3000
```

3. **Check Express connecting to Flask:**

```bash
curl http://<express_instance_public_ip>:3000/api/data
```

This should show data fetched from the Flask backend instance.

### Security Group Configuration

The security groups are configured to:
- Allow SSH access from your IP (or 0.0.0.0/0 if configured)
- Allow Flask port (5000) from internet
- Allow Express port (3000) from internet
- Allow Flask to receive traffic from Express instance's security group

### Screenshots/Commands

Take screenshots of:
- `terraform plan` output showing VPC resources
- `terraform apply` output
- `terraform output` showing both instance IPs
- VPC, subnets, and security groups in AWS Console
- `curl` commands showing inter-instance communication

## Part 3: Docker with ECS/ECR/ALB

Deploy Flask and Express as Docker containers using ECS Fargate, ECR, and Application Load Balancer.

### Steps

1. **Navigate to Part 3 directory:**

```bash
cd part3-docker-ecs
```

2. **Create terraform.tfvars file:**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
project_name = "flask-express"
```

3. **Initialize Terraform:**

```bash
terraform init
```

4. **Review the execution plan:**

```bash
terraform plan
```

This will show resources to be created:
- VPC with public and private subnets
- NAT Gateways
- ECR repositories (Flask and Express)
- ECS Cluster
- ECS Task Definitions
- ECS Services
- Application Load Balancer
- Target Groups
- Security Groups
- IAM Roles

5. **Apply the configuration (first time - creates infrastructure):**

```bash
terraform apply
```

Type `yes` when prompted. This creates all AWS resources but services won't have images yet.

6. **Get ECR repository URLs:**

```bash
terraform output ecr_flask_repository_url
terraform output ecr_express_repository_url
```

7. **Build and push Docker images:**

**On Linux/Mac:**
```bash
chmod +x build-and-push.sh
./build-and-push.sh us-east-1
```

**On Windows (PowerShell):**
```powershell
.\build-and-push.ps1 -AwsRegion us-east-1
```

**Or manually:**

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <flask-repo-url>

# Build and push Flask
cd ../flask-app
docker build -t <flask-repo-url>:latest .
docker push <flask-repo-url>:latest

# Build and push Express
cd ../express-app
docker build -t <express-repo-url>:latest .
docker push <express-repo-url>:latest
```

8. **Get ALB DNS name:**

```bash
terraform output alb_dns_name
```

### Verification

1. **Check Express frontend (default route):**

```bash
curl http://<alb-dns-name>/
```

2. **Check Express health:**

```bash
curl http://<alb-dns-name>/health
```

3. **Check Express fetching data from Flask:**

```bash
curl http://<alb-dns-name>/api/data
```

4. **Check Flask backend directly (via /backend path):**

```bash
curl http://<alb-dns-name>/backend/
```

5. **Check Flask health endpoint:**

```bash
curl http://<alb-dns-name>/backend/api/health
```

### ALB Configuration

The Application Load Balancer is configured with:
- **Default listener (port 80)**: Routes to Express frontend (default route)
- **Path-based routing**: Routes `/backend/*` to Flask backend
- **Health checks**: Configured for both services
- **Target groups**: Separate target groups for Flask and Express
- **Express connects to Flask**: Express service uses ALB DNS to communicate with Flask backend

### Screenshots/Commands

Take screenshots of:
- `terraform plan` output showing ECS/ECR resources
- `terraform apply` output
- ECR repositories in AWS Console
- Docker build and push commands
- ECS cluster and services in AWS Console
- ALB and target groups in AWS Console
- `curl` commands showing ALB routing
- CloudWatch logs for ECS tasks

## Terraform State Management

### Using S3 Backend (Recommended)

For production use, configure Terraform to store state in S3:

1. **Create S3 bucket for state:**

```bash
aws s3 mb s3://your-terraform-state-bucket --region us-east-1
```

2. **Enable versioning:**

```bash
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

3. **Create DynamoDB table for locking:**

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

4. **Copy backend configuration:**

```bash
cp backend.tf.example backend.tf
```

5. **Edit backend.tf** and update:
- `bucket`: Your S3 bucket name
- `key`: Path for state file (e.g., `part1/terraform.tfstate`)
- `region`: Your AWS region
- `dynamodb_table`: Your DynamoDB table name

6. **Reinitialize Terraform:**

```bash
terraform init -migrate-state
```

This migrates your local state to S3.

## Troubleshooting

### Part 1 & 2: EC2 Issues

**Services not starting:**
```bash
# SSH into instance
ssh -i your-key.pem ec2-user@<instance-ip>

# Check service status
sudo systemctl status flask-app
sudo systemctl status express-app

# Check logs
sudo journalctl -u flask-app -f
sudo journalctl -u express-app -f
```

**Port not accessible:**
- Check security group rules
- Verify instance is running
- Check if services are listening: `sudo netstat -tlnp`

### Part 3: ECS Issues

**Tasks not starting:**
- Check ECS service events in AWS Console
- Verify Docker images are pushed to ECR
- Check CloudWatch logs: `/ecs/flask-express-flask` and `/ecs/flask-express-express`
- Verify task definition has correct image URI

**ALB health checks failing:**
- Check target group health in AWS Console
- Verify health check path is correct
- Check security groups allow traffic from ALB to ECS tasks

**Images not found:**
```bash
# Verify images in ECR
aws ecr describe-images --repository-name flask-express-flask
aws ecr describe-images --repository-name flask-express-express
```

## Cleanup

### Part 1: Destroy Resources

```bash
cd part1-single-ec2
terraform destroy
```

### Part 2: Destroy Resources

```bash
cd part2-separate-ec2
terraform destroy
```

### Part 3: Destroy Resources

```bash
cd part3-docker-ecs
terraform destroy
```

**Note:** ECR repositories will be deleted, but images may remain. Manually delete images if needed:

```bash
aws ecr batch-delete-image \
  --repository-name flask-express-flask \
  --image-ids imageTag=latest

aws ecr batch-delete-image \
  --repository-name flask-express-express \
  --image-ids imageTag=latest
```

## Cost Considerations

- **Part 1**: ~$8-10/month (1 t2.micro instance)
- **Part 2**: ~$16-20/month (2 t2.micro instances + NAT Gateway)
- **Part 3**: ~$20-30/month (ECS Fargate tasks + ALB + NAT Gateways)

Use `t2.micro` instances for free tier eligibility (first 12 months).

## Security Best Practices

1. **Restrict SSH access**: Update `allowed_cidr` to your IP instead of `0.0.0.0/0`
2. **Use HTTPS**: Configure SSL/TLS certificates for ALB in Part 3
3. **Secrets management**: Use AWS Secrets Manager for sensitive data
4. **IAM roles**: Follow principle of least privilege
5. **VPC**: Use private subnets for ECS tasks (already configured in Part 3)

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

## Submission Checklist

- [ ] Part 1 deployed and verified
- [ ] Part 2 deployed and verified
- [ ] Part 3 deployed and verified
- [ ] Screenshots of terraform commands
- [ ] Screenshots of AWS Console resources
- [ ] Screenshots of application responses
- [ ] GitHub repository link shared
- [ ] Documentation in Google Doc or Microsoft Word format

## License

This project is for educational purposes.
