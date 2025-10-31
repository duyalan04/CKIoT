// config/mqtt.js - MQTT Client Configuration
const mqtt = require('mqtt');

// Generate unique ClientID to avoid conflicts
const generateClientId = () => {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(7);
  return `BackendServer_${timestamp}_${random}`;
};

const mqttClient = mqtt.connect(process.env.MQTT_BROKER || 'mqtt://broker.emqx.io', {
  clientId: process.env.MQTT_CLIENT_ID || generateClientId(),
  clean: true,
  reconnectPeriod: 5000, // Tăng lên 5s để tránh reconnect liên tục
  connectTimeout: 30000, // 30s timeout
});

mqttClient.on('connect', () => {
  console.log('✅ Connected to MQTT broker:', process.env.MQTT_BROKER || 'mqtt://broker.emqx.io');
  console.log('🆔 Client ID:', mqttClient.options.clientId);
  
  // Subscribe to STATE topics từ ESP32
  const topics = [
    process.env.MQTT_TOPIC_LED_STATE || 'home/led/state',
    process.env.MQTT_TOPIC_FAN_STATE || 'home/fan/state'
  ];
  
  mqttClient.subscribe(topics, (err) => {
    if (err) {
      console.error('❌ MQTT subscription error:', err);
    } else {
      console.log('✅ Subscribed to ESP32 state topics:', topics);
    }
  });
});

mqttClient.on('error', (err) => {
  console.error('❌ MQTT connection error:', err);
});

mqttClient.on('reconnect', () => {
  console.log('🔄 Reconnecting to MQTT broker...');
});

mqttClient.on('offline', () => {
  console.log('⚠️ MQTT client offline');
});

module.exports = mqttClient;
