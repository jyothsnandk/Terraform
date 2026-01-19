#!/bin/bash
set -e

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip git

# Install Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Verify installations
python3 --version
node --version
npm --version

# Create application directories
mkdir -p /opt/flask-app
mkdir -p /opt/express-app

# Clone or create Flask application
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

# Create Express application
cat > /opt/express-app/package.json << 'EOF'
{
  "name": "express-frontend",
  "version": "1.0.0",
  "description": "Express Frontend Application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "axios": "^1.6.0"
  }
}
EOF

cat > /opt/express-app/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || ${express_port};
const FLASK_BACKEND_URL = process.env.FLASK_BACKEND_URL || 'http://localhost:${flask_port}';

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'express-frontend',
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'Express Frontend API',
    status: 'running',
    version: '1.0.0',
    backend_url: FLASK_BACKEND_URL
  });
});

app.get('/api/data', async (req, res) => {
  try {
    const response = await axios.get(FLASK_BACKEND_URL + '/api/data');
    res.json({
      source: 'express-frontend',
      backend_data: response.data
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch data from backend',
      message: error.message
    });
  }
});

app.get('/api/backend-health', async (req, res) => {
  try {
    const response = await axios.get(FLASK_BACKEND_URL + '/api/health');
    res.json({
      frontend: 'healthy',
      backend: response.data
    });
  } catch (error) {
    res.status(503).json({
      frontend: 'healthy',
      backend: 'unreachable',
      error: error.message
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('Express server running on port ' + PORT);
  console.log('Backend URL: ' + FLASK_BACKEND_URL);
});
EOF

# Install Express dependencies
cd /opt/express-app
npm install

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

# Create systemd service for Express
cat > /etc/systemd/system/express-app.service << EOF
[Unit]
Description=Express Frontend Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/express-app
Environment="PORT=${express_port}"
Environment="FLASK_BACKEND_URL=http://localhost:${flask_port}"
ExecStart=/usr/bin/node /opt/express-app/server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
systemctl daemon-reload
systemctl enable flask-app
systemctl enable express-app
systemctl start flask-app
systemctl start express-app

# Wait a bit for services to start
sleep 10

# Check service status
systemctl status flask-app --no-pager || true
systemctl status express-app --no-pager || true
