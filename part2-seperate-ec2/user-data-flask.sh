#!/bin/bash
set -e

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip git

# Verify installation
python3 --version

# Create application directory
mkdir -p /opt/flask-app

# Create Flask application
cat > /opt/flask-app/app.py << 'EOF'
from flask import Flask, jsonify, request
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return jsonify({
        'message': 'Flask Backend API',
        'status': 'running',
        'version': '1.0.0'
    })

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'flask-backend'
    })

@app.route('/api/data', methods=['GET'])
def get_data():
    return jsonify({
        'data': [
            {'id': 1, 'name': 'Item 1', 'description': 'First item'},
            {'id': 2, 'name': 'Item 2', 'description': 'Second item'},
            {'id': 3, 'name': 'Item 3', 'description': 'Third item'}
        ]
    })

@app.route('/api/data', methods=['POST'])
def create_data():
    data = request.get_json()
    return jsonify({
        'message': 'Data created successfully',
        'data': data
    }), 201

if __name__ == '__main__':
    port = int(os.environ.get('PORT', ${flask_port}))
    app.run(host='0.0.0.0', port=port, debug=True)
EOF

cat > /opt/flask-app/requirements.txt << 'EOF'
Flask==3.0.0
flask-cors==4.0.0
EOF

# Install Flask dependencies
cd /opt/flask-app
pip3 install -r requirements.txt

# Create systemd service for Flask
cat > /etc/systemd/system/flask-app.service << EOF
[Unit]
Description=Flask Backend Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/flask-app
Environment="PORT=${flask_port}"
ExecStart=/usr/bin/python3 /opt/flask-app/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable flask-app
systemctl start flask-app

# Wait a bit for service to start
sleep 10

# Check service status
systemctl status flask-app --no-pager || true
