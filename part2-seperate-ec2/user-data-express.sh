#!/bin/bash
set -e

# Update system
yum update -y

# Install Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git

# Verify installation
node --version
npm --version

# Create application directory
mkdir -p /opt/express-app

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

cat > /opt/express-app/server.js << EOF
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || ${express_port};
const FLASK_BACKEND_URL = process.env.FLASK_BACKEND_URL || 'http://${flask_backend_ip}:${flask_port}';

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
Environment="FLASK_BACKEND_URL=http://${flask_backend_ip}:${flask_port}"
ExecStart=/usr/bin/node /opt/express-app/server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable express-app
systemctl start express-app

# Wait a bit for service to start
sleep 10

# Check service status
systemctl status express-app --no-pager || true
