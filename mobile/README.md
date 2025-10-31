# 📱 Smart Home Mobile App

Flutter mobile application để điều khiển smart home với ESP32, MQTT, PostgreSQL và Google Assistant.

## 🌟 Tính năng

### 1. Điều khiển thiết bị
- **LED Control**: Nút bật/tắt đèn LED với gradient card design
- **Fan Control**: Nút bật/tắt quạt và slider điều chỉnh tốc độ (0-255)
- Hiển thị trạng thái real-time
- Auto-refresh mỗi 5 giây

### 2. Trạng thái hệ thống
- Server, PostgreSQL, MQTT, ESP32 status
- Icons màu sắc: 🟢🔴🟡

### 3. Voice Control
- Speech Recognition (tiếng Việt)
- 6 lệnh: Bật/Tắt đèn, quạt, tất cả

## 🚀 Quick Start

```bash
cd mobile
flutter pub get
flutter run
```

## ⚙️ Cấu hình API

Mở `lib/services/api_service.dart`:
```dart
// Android emulator:
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Real device (same WiFi - thay IP):
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

## 📁 Cấu trúc

```
lib/
├── models/device.dart           # Models
├── services/api_service.dart    # API
├── widgets/
│   ├── device_card.dart
│   ├── system_status_bar.dart
│   └── voice_control_button.dart
└── main.dart
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ⚠️ Web (limited voice support)

## 🔗 Related

- Backend: `../backend/README.md`
- Web: `../web/README.md`
- MQTT: `../MQTT_INTEGRATION.md`
