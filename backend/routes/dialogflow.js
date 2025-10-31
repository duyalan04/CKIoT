// routes/dialogflow.js - Dialogflow Webhook Routes
const express = require('express');
const router = express.Router();
const GoogleAssistantController = require('../controllers/googleAssistantController');

// Google Assistant webhook endpoint
router.post('/google-assistant', GoogleAssistantController.handleWebhook);

module.exports = router;