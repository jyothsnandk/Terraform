output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "flask_url" {
  description = "URL to access Flask backend"
  value       = "http://${aws_instance.app_server.public_ip}:${var.flask_port}"
}

output "express_url" {
  description = "URL to access Express frontend"
  value       = "http://${aws_instance.app_server.public_ip}:${var.express_port}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.app_server.public_ip}"
}
