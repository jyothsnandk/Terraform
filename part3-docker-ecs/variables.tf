variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "flask-express"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "flask_port" {
  description = "Port for Flask backend"
  type        = number
  default     = 5000
}

variable "express_port" {
  description = "Port for Express frontend"
  type        = number
  default     = 3000
}

variable "flask_cpu" {
  description = "CPU units for Flask task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "flask_memory" {
  description = "Memory for Flask task in MB"
  type        = number
  default     = 512
}

variable "express_cpu" {
  description = "CPU units for Express task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "express_memory" {
  description = "Memory for Express task in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks for each service"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "Flask-Express-Deployment"
    Environment = "Development"
    Part        = "Part3-Docker-ECS"
  }
}
variable "key_name" {
  description = "tutedude-new"
  type        = string
}

