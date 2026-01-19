const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const FLASK_BACKEND_URL = process.env.FLASK_BACKEND_URL || 'http://localhost:5000';

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'express-frontend',
    timestamp: new Date().toISOString()
  });
});

// Home page
app.get('/', (req, res) => {
  res.json({
    message: 'Express Frontend API',
    status: 'running',
    version: '1.0.0',
    backend_url: FLASK_BACKEND_URL
  });
});

// Proxy endpoint to Flask backend
app.get('/api/data', async (req, res) => {
  try {
    const response = await axios.get(`${FLASK_BACKEND_URL}/api/data`);
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

// Health check for backend
app.get('/api/backend-health', async (req, res) => {
  try {
    const response = await axios.get(`${FLASK_BACKEND_URL}/api/health`);
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
  console.log(`Express server running on port ${PORT}`);
  console.log(`Backend URL: ${FLASK_BACKEND_URL}`);
});
