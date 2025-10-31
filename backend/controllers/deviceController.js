// controllers/deviceController.js - Device Controller
const Device = require('../models/Device');
const MqttService = require('../services/mqttService');

class DeviceController {
  
  // Lấy tất cả thiết bị
  static async getAllDevices(req, res) {
    try {
      const devices = await Device.getAll();
      res.json({
        success: true,
        data: devices
      });
    } catch (error) {
      console.error('Error fetching devices:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  // Lấy thiết bị theo ID
  static async getDeviceById(req, res) {
    try {
      const { id } = req.params;
      const device = await Device.getById(id);
      
      if (!device) {
        return res.status(404).json({
          success: false,
          error: 'Device not found'
        });
      }
      
      res.json({
        success: true,
        data: device
      });
    } catch (error) {
      console.error('Error fetching device:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  // Điều khiển LED
  static async controlLED(req, res) {
    try {
      const { state } = req.body;
      
      if (!state || !['on', 'off'].includes(state)) {
        return res.status(400).json({
          success: false,
          error: 'Invalid state. Use "on" or "off"'
        });
      }
      
      // Gửi lệnh qua MQTT
      await MqttService.publishLED(state);
      
      // Cập nhật database
      await Device.updateState('LED', state);
      
      res.json({
        success: true,
        message: `LED turned ${state}`,
        data: { state }
      });
      
    } catch (error) {
      console.error('Error controlling LED:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  // Điều khiển quạt
  static async controlFan(req, res) {
    try {
      const { state, speed } = req.body;
      
      if (!state || !['on', 'off'].includes(state)) {
        return res.status(400).json({
          success: false,
          error: 'Invalid state. Use "on" or "off"'
        });
      }
      
      const fanSpeed = state === 'on' ? (speed || 255) : 0;
      
      // Gửi lệnh qua MQTT
      await MqttService.publishFan(state, fanSpeed);
      
      // Cập nhật database
      await Device.updateState('Fan', state, fanSpeed);
      
      res.json({
        success: true,
        message: `Fan turned ${state}`,
        data: { state, speed: fanSpeed }
      });
      
    } catch (error) {
      console.error('Error controlling fan:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  // Điều khiển tất cả thiết bị
  static async controlAll(req, res) {
    try {
      const { state } = req.body;
      
      if (!state || !['on', 'off'].includes(state)) {
        return res.status(400).json({
          success: false,
          error: 'Invalid state. Use "on" or "off"'
        });
      }
      
      // Gửi lệnh cho LED
      await MqttService.publishLED(state);
      await Device.updateState('LED', state);
      
      // Gửi lệnh cho Fan
      const fanSpeed = state === 'on' ? 255 : 0;
      await MqttService.publishFan(state, fanSpeed);
      await Device.updateState('Fan', state, fanSpeed);
      
      res.json({
        success: true,
        message: `All devices turned ${state}`,
        data: { 
          led: { state },
          fan: { state, speed: fanSpeed }
        }
      });
      
    } catch (error) {
      console.error('Error controlling all devices:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  // Lấy logs thiết bị
  static async getDeviceLogs(req, res) {
    try {
      const { device, limit = 50 } = req.query;
      
      const logs = await Device.getLogs(device, limit);
      
      res.json({
        success: true,
        data: logs
      });
    } catch (error) {
      console.error('Error fetching logs:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  // Lấy trạng thái hệ thống
  static async getSystemStatus(req, res) {
    try {
      const mqttClient = require('../config/mqtt');
      const pool = require('../config/db');
      
      const dbStatus = await pool.query('SELECT NOW()');
      const moment = require('moment');
      
      res.json({
        success: true,
        data: {
          server: 'running',
          database: dbStatus.rows.length > 0 ? 'connected' : 'disconnected',
          mqtt: mqttClient.connected ? 'connected' : 'disconnected',
          timestamp: moment().format('YYYY-MM-DD HH:mm:ss')
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = DeviceController;
