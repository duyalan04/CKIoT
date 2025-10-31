// controllers/googleAssistantController.js - Google Assistant Webhook Controller
const Device = require('../models/Device');
const MqttService = require('../services/mqttService');

class GoogleAssistantController {
  
  static async handleWebhook(req, res) {
    try {
      console.log('📞 Google Assistant Request:', JSON.stringify(req.body, null, 2));
      
      const { queryResult } = req.body;
      
      if (!queryResult || !queryResult.intent) {
        return res.status(400).json({
          fulfillmentText: 'Invalid request format',
          source: 'smart-home-backend'
        });
      }
      
      const intent = queryResult.intent.displayName;
      const parameters = queryResult.parameters || {};
      
      console.log('🎯 Intent:', intent);
      console.log('📋 Parameters:', parameters);
      
      let responseText = '';
      let success = false;
      
      switch (intent) {
        case 'TurnOnLED':
        case 'BatDen':
          await MqttService.publishLED('on');
          await Device.updateState('LED', 'on');
          responseText = 'Đã bật đèn LED';
          success = true;
          break;
          
        case 'TurnOffLED':
        case 'TatDen':
          await MqttService.publishLED('off');
          await Device.updateState('LED', 'off');
          responseText = 'Đã tắt đèn LED';
          success = true;
          break;
          
        case 'TurnOnFan':
        case 'BatQuat':
          const fanSpeedOn = parameters.speed ? parseInt(parameters.speed) : 255;
          await MqttService.publishFan('on', fanSpeedOn);
          await Device.updateState('Fan', 'on', fanSpeedOn);
          responseText = fanSpeedOn === 255 
            ? 'Đã bật quạt ở tốc độ tối đa' 
            : `Đã bật quạt ở tốc độ ${fanSpeedOn}`;
          success = true;
          break;
          
        case 'TurnOffFan':
        case 'TatQuat':
          await MqttService.publishFan('off', 0);
          await Device.updateState('Fan', 'off', 0);
          responseText = 'Đã tắt quạt';
          success = true;
          break;
          
        case 'SetFanSpeed':
        case 'DatTocDoQuat':
          const speedValue = parseInt(parameters.speed) || 128;
          const normalizedSpeed = Math.min(255, Math.max(0, speedValue));
          await MqttService.publishFan('on', normalizedSpeed);
          await Device.updateState('Fan', 'on', normalizedSpeed);
          responseText = `Đã đặt tốc độ quạt là ${normalizedSpeed}`;
          success = true;
          break;
          
        case 'GetDeviceStatus':
        case 'KiemTraThietBi':
          const deviceName = parameters.device || parameters['device-name'];
          if (!deviceName) {
            responseText = 'Bạn muốn kiểm tra thiết bị nào? Đèn hay quạt?';
          } else {
            const device = await Device.getByName(deviceName);
            if (device) {
              const status = device.state === 'on' ? 'đang bật' : 'đang tắt';
              responseText = device.type === 'fan' && device.state === 'on'
                ? `${device.name} ${status} ở tốc độ ${device.speed || 0}`
                : `${device.name} ${status}`;
            } else {
              responseText = `Không tìm thấy thiết bị ${deviceName}`;
            }
          }
          success = true;
          break;
          
        case 'GetAllDevices':
        case 'TatCaThietBi':
          const allDevices = await Device.getAll();
          if (allDevices.length > 0) {
            const statuses = allDevices.map(d => {
              const status = d.state === 'on' ? 'bật' : 'tắt';
              return d.type === 'fan' && d.state === 'on'
                ? `${d.name} đang ${status} ở tốc độ ${d.speed || 0}`
                : `${d.name} đang ${status}`;
            });
            responseText = 'Trạng thái các thiết bị: ' + statuses.join(', ');
          } else {
            responseText = 'Không có thiết bị nào';
          }
          success = true;
          break;
          
        case 'TurnOnAll':
        case 'BatTatCa':
          await MqttService.publishAll('on');
          await Device.updateAll('on');
          responseText = 'Đã bật tất cả thiết bị';
          success = true;
          break;
          
        case 'TurnOffAll':
        case 'TatTatCa':
          await MqttService.publishAll('off');
          await Device.updateAll('off');
          responseText = 'Đã tắt tất cả thiết bị';
          success = true;
          break;
          
        default:
          responseText = 'Xin lỗi, tôi chưa hiểu yêu cầu của bạn. Bạn có thể nói "bật đèn", "tắt quạt", hoặc "kiểm tra thiết bị"';
      }
      
      console.log(`✅ Response: ${responseText}`);
      
      res.json({
        fulfillmentText: responseText,
        fulfillmentMessages: [{
          text: {
            text: [responseText]
          }
        }],
        source: 'smart-home-backend',
        payload: {
          success,
          intent,
          timestamp: new Date().toISOString()
        }
      });
      
    } catch (error) {
      console.error('❌ Error handling Google Assistant request:', error);
      res.status(500).json({
        fulfillmentText: 'Đã xảy ra lỗi khi xử lý yêu cầu. Vui lòng thử lại.',
        source: 'smart-home-backend',
        payload: {
          error: error.message
        }
      });
    }
  }
}

module.exports = GoogleAssistantController;
