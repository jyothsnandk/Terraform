terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "flask-express-single-instance-sg"
  description = "Security group for Flask and Express on single instance"

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # Flask backend
  ingress {
    description = "Flask Backend"
    from_port   = var.flask_port
    to_port     = var.flask_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # Express frontend
  ingress {
    description = "Express Frontend"
    from_port   = var.express_port
    to_port     = var.express_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # Outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    flask_port   = var.flask_port
    express_port = var.express_port
  }))

  tags = merge(var.tags, {
    Name = "Flask-Express-Single-Instance"
  })
}
