output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "flask_instance_id" {
  description = "ID of the Flask backend EC2 instance"
  value       = aws_instance.flask_backend.id
}

output "flask_instance_public_ip" {
  description = "Public IP address of the Flask backend instance"
  value       = aws_instance.flask_backend.public_ip
}

output "flask_instance_private_ip" {
  description = "Private IP address of the Flask backend instance"
  value       = aws_instance.flask_backend.private_ip
}

output "flask_url" {
  description = "URL to access Flask backend"
  value       = "http://${aws_instance.flask_backend.public_ip}:${var.flask_port}"
}

output "express_instance_id" {
  description = "ID of the Express frontend EC2 instance"
  value       = aws_instance.express_frontend.id
}

output "express_instance_public_ip" {
  description = "Public IP address of the Express frontend instance"
  value       = aws_instance.express_frontend.public_ip
}

output "express_url" {
  description = "URL to access Express frontend"
  value       = "http://${aws_instance.express_frontend.public_ip}:${var.express_port}"
}

output "flask_ssh_command" {
  description = "SSH command to connect to Flask instance"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.flask_backend.public_ip}"
}

output "express_ssh_command" {
  description = "SSH command to connect to Express instance"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.express_frontend.public_ip}"
}
