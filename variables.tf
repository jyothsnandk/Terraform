variable "region" {
  default = "us-east-1"
}

variable "ami" {
  description = "Amazon Linux 2 AMI ID"
  default     = "ami-0c02fb55956c7d316" # Update with your region AMI
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 Key Pair name"
  default     = "my-key"  # Replace with your key
}
