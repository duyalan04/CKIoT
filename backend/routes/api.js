// routes/api.js - API Routes
const express = require('express');
const router = express.Router();
const DeviceController = require('../controllers/deviceController');

// Health check
router.get('/', (req, res) => {
  const moment = require('moment');
  const mqttClient = require('../config/mqtt');
  
  res.json({
    status: 'running',
    message: 'Smart Home Backend API',
    timestamp: moment().format('YYYY-MM-DD HH:mm:ss'),
    mqtt: mqttClient.connected ? 'connected' : 'disconnected',
    database: 'connected'
  });
});

// Device routes
router.get('/devices', DeviceController.getAllDevices);
router.get('/devices/:id', DeviceController.getDeviceById);

// Control routes
router.post('/led', DeviceController.controlLED);
router.post('/fan', DeviceController.controlFan);
router.post('/all', DeviceController.controlAll);

// Logs route
router.get('/logs', DeviceController.getDeviceLogs);

// Status route
router.get('/status', DeviceController.getSystemStatus);

module.exports = router;
