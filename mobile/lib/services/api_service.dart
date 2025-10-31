// lib/services/api_service.dart - API Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class ApiService {
  // ✅ IP máy tính chạy backend: 192.168.1.12
  // Điện thoại phải cùng WiFi với máy tính!
  static const String baseUrl = 'http://192.168.1.12:3000/api';

  // Nếu test trên emulator Android, dùng:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Nếu test trên iOS simulator, dùng:
  // static const String baseUrl = 'http://localhost:3000/api';

  // Lấy danh sách thiết bị
  static Future<List<Device>> getDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/devices'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> devicesJson = data['data'];
          return devicesJson.map((json) => Device.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load devices');
    } catch (e) {
      print('Error fetching devices: $e');
      rethrow;
    }
  }

  // Điều khiển LED
  static Future<bool> controlLED(String state) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/led'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'state': state}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error controlling LED: $e');
      return false;
    }
  }

  // Điều khiển quạt
  static Future<bool> controlFan(String state, {int speed = 255}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'state': state, 'speed': speed}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error controlling fan: $e');
      return false;
    }
  }

  // Điều khiển tất cả thiết bị
  static Future<bool> controlAll(String state) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/all'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'state': state}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error controlling all devices: $e');
      return false;
    }
  }

  // Lấy trạng thái hệ thống
  static Future<SystemStatus?> getSystemStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return SystemStatus.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching system status: $e');
      return null;
    }
  }
}
