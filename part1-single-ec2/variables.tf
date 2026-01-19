variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
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

variable "allowed_cidr" {
  description = "CIDR block allowed to access the applications"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "Flask-Express-Deployment"
    Environment = "Development"
    Part        = "Part1-SingleEC2"
  }
}
