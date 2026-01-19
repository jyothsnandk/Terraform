provider "aws" {
  region = var.region
}

# -------------------
# Security Group
# -------------------
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP 3000 and Flask 5000"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------
# EC2 Instance
# -------------------
resource "aws_instance" "web_server" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # --- Python + Flask ---
              yum install -y python3 python3-pip
              pip3 install flask flask-cors

              # Flask app
              mkdir -p /home/ec2-user/flask-app
              cat <<EOT > /home/ec2-user/flask-app/app.py
              from flask import Flask
              from flask_cors import CORS
              import os
              app = Flask(__name__)
              CORS(app)
              
              @app.route('/')
              def home():
                  return "Flask Backend Running on Port 5000"

              if __name__ == "__main__":
                  port = int(os.environ.get('PORT', 5000))
                  app.run(host='0.0.0.0', port=port, debug=False)
              EOT

              nohup python3 /home/ec2-user/flask-app/app.py > /home/ec2-user/flask-app/flask.log 2>&1 &

              # --- Node.js + Express ---
              curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
              yum install -y nodejs

              mkdir -p /home/ec2-user/express-app
              cd /home/ec2-user/express-app
              npm init -y
              npm install express

              cat <<EOT > /home/ec2-user/express-app/index.js
              const express = require('express');
              const app = express();

              app.get('/', (req, res) => {
                res.send('Express Frontend Running on Port 3000');
              });

              app.listen(3000, '0.0.0.0', () => {
                console.log('Express running on port 3000');
              });
              EOT

              nohup node /home/ec2-user/express-app/index.js > /home/ec2-user/express-app/express.log 2>&1 &
              EOF

  tags = {
    Name = "Flask-Express-Server"
  }
}
