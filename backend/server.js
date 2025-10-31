// server.js - Main Application Entry Point
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

// Import configurations
require('./config/db');
const mqttClient = require('./config/mqtt');

// Import services
const MqttService = require('./services/mqttService');

// Import routes
const apiRoutes = require('./routes/api');
const dialogflowRoutes = require('./routes/dialogflow');

// Initialize Express app
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Setup MQTT message listeners
MqttService.setupListeners();

// Routes
app.use('/api', apiRoutes);
app.use('/api', dialogflowRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Smart Home API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      api: '/api',
      devices: '/api/devices',
      led: '/api/led',
      fan: '/api/fan',
      logs: '/api/logs',
      status: '/api/status',
      googleAssistant: '/api/google-assistant'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('❌ Error:', err.stack);
  res.status(500).json({
    success: false,
    error: err.message || 'Internal Server Error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

// Start server
app.listen(port, () => {
  console.log('');
  console.log('='.repeat(50));
  console.log('🚀 Smart Home Backend Server');
  console.log('='.repeat(50));
  console.log(`📡 Server running on port ${port}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 API URL: http://localhost:${port}/api`);
  console.log('='.repeat(50));
  console.log('');
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n⚠️ Shutting down gracefully...');
  mqttClient.end();
  process.exit(0);
});

module.exports = app;
