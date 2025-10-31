// services/mqttService.js - MQTT Service
const mqttClient = require('../config/mqtt');
const Device = require('../models/Device');

class MqttService {
  
  // Gửi lệnh điều khiển LED (tương thích ESP32)
  static publishLED(state) {
    return new Promise((resolve, reject) => {
      const topic = process.env.MQTT_TOPIC_LED_SET || 'home/led/set';
      // ESP32 đọc "ON" hoặc "OFF" (uppercase)
      const message = state === 'on' ? 'ON' : 'OFF';
      
      mqttClient.publish(topic, message, { qos: 1 }, (err) => {
        if (err) {
          console.error('❌ MQTT publish error (LED):', err);
          reject(err);
        } else {
          console.log(`✅ Published to ${topic}: ${message}`);
          resolve({ topic, message });
        }
      });
    });
  }

  // Gửi lệnh điều khiển quạt (tương thích ESP32)
  static publishFan(state, speed = 255) {
    return new Promise((resolve, reject) => {
      const topic = process.env.MQTT_TOPIC_FAN_SET || 'home/fan/set';
      // ESP32 đọc "ON" hoặc "OFF" (uppercase)
      const message = state === 'on' ? 'ON' : 'OFF';
      
      mqttClient.publish(topic, message, { qos: 1 }, (err) => {
        if (err) {
          console.error('❌ MQTT publish error (Fan):', err);
          reject(err);
        } else {
          console.log(`✅ Published to ${topic}: ${message} (speed: ${speed})`);
          resolve({ topic, message, speed });
        }
      });
    });
  }

  // Gửi lệnh điều khiển tất cả
  static async publishAll(state) {
    const ledPromise = this.publishLED(state);
    const fanPromise = this.publishFan(state, state === 'on' ? 255 : 0);
    
    return Promise.all([ledPromise, fanPromise]);
  }

  // Xử lý message nhận được từ ESP32 (state feedback)
  static handleMessage(topic, message) {
    const payload = message.toString(); // "ON" hoặc "OFF" từ ESP32
    console.log(`📨 Received from ESP32 on ${topic}: ${payload}`);
    
    try {
      // Parse topic: home/led/state => led
      const parts = topic.split('/');
      const deviceType = parts[1]; // led hoặc fan
      
      // Convert "ON"/"OFF" sang "on"/"off" cho database
      const state = payload.toUpperCase() === 'ON' ? 'on' : 'off';
      
      // Cập nhật state trong database
      Device.updateState(deviceType.toUpperCase(), state)
        .then(() => {
          console.log(`✅ Updated ${deviceType} state to ${state} in database`);
        })
        .catch(err => console.error('Error updating device state:', err));
      
      // Ghi log action
      Device.logAction(deviceType, 'state_update', state)
        .catch(err => console.error('Error logging device action:', err));
      
    } catch (error) {
      console.error('Error processing MQTT message:', error);
    }
  }

  // Setup message listener
  static setupListeners() {
    mqttClient.on('message', (topic, message) => {
      this.handleMessage(topic, message);
    });
  }
}

module.exports = MqttService;
