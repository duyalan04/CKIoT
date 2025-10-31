# Smart Home Web Dashboard 🏠

Giao diện web điều khiển smart home với ESP32, MQTT, PostgreSQL và Google Assistant.

## 🌟 Tính năng

### 1. Điều khiển thiết bị
- **LED Control**: Bật/tắt đèn LED với nút toggle
- **Fan Control**: Bật/tắt quạt với nút toggle
- Hiển thị trạng thái real-time của từng thiết bị
- Cập nhật tự động mỗi 5 giây

### 2. Trạng thái hệ thống
- Hiển thị kết nối Server (Backend)
- Hiển thị kết nối PostgreSQL Database
- Hiển thị kết nối MQTT Broker
- Hiển thị kết nối ESP32
- Auto-refresh status indicators

### 3. Điều khiển bằng giọng nói
- Web Speech API cho nhận dạng giọng nói tiếng Việt
- Các lệnh hỗ trợ:
  - "Bật đèn" / "Tắt đèn"
  - "Bật quạt" / "Tắt quạt"
  - "Bật tất cả" / "Tắt tất cả"
- Tích hợp Google Assistant qua Actions on Google

## 🚀 Cài đặt

### 1. Cài đặt dependencies
```bash
cd web
npm install
```

### 2. Cấu hình môi trường
Copy file `.env.example` thành `.env`:
```bash
copy .env.example .env
```

Chỉnh sửa `.env`:
```env
REACT_APP_API_URL=http://localhost:3000/api
```

### 3. Chạy development server
```bash
npm start
```

Web sẽ chạy tại: http://localhost:3001

## 📁 Cấu trúc thư mục

```
web/
├── public/
│   ├── index.html          # HTML template
│   └── manifest.json       # PWA manifest
├── src/
│   ├── components/
│   │   ├── DeviceCard.jsx      # Component hiển thị thiết bị
│   │   ├── SystemStatus.jsx    # Component trạng thái hệ thống
│   │   └── VoiceControl.jsx    # Component điều khiển giọng nói
│   ├── services/
│   │   └── api.js              # API service layer
│   ├── App.js              # Main App component
│   ├── App.css             # Styles
│   └── index.js            # Entry point
├── package.json
├── .env                    # Environment variables
└── README.md
```

## 🎨 Components

### DeviceCard
Component hiển thị thông tin và điều khiển thiết bị:
- Props:
  - `device`: Object chứa thông tin thiết bị
  - `onToggle`: Function callback khi bật/tắt

### SystemStatus
Component hiển thị trạng thái hệ thống:
- Props:
  - `status`: Object chứa trạng thái các service
  - `loading`: Boolean hiển thị loading state

### VoiceControl
Component điều khiển bằng giọng nói:
- Props:
  - `onCommand`: Function callback khi nhận được lệnh voice
- Features:
  - Web Speech API integration
  - Real-time transcript display
  - Command list helper

## 🔌 API Integration

### ApiService Methods

#### getDevices()
```javascript
const devices = await ApiService.getDevices();
// Response: { success: true, data: [...] }
```

#### controlLED(state)
```javascript
await ApiService.controlLED('on');  // hoặc 'off'
// Response: { success: true, message: '...' }
```

#### controlFan(state, speed)
```javascript
await ApiService.controlFan('on', 200);
// Response: { success: true, message: '...' }
```

#### getSystemStatus()
```javascript
const status = await ApiService.getSystemStatus();
// Response: { success: true, data: { server, database, mqtt } }
```

## 🎯 Sử dụng

### 1. Điều khiển qua Web UI
- Click nút "🟢 BẬT" / "🔴 TẮT" để bật/tắt thiết bị
- Theo dõi trạng thái real-time trên dashboard

### 2. Điều khiển bằng giọng nói
- Click nút "🎤 Nhấn để nói"
- Nói lệnh bằng tiếng Việt
- Ví dụ: "Bật đèn", "Tắt quạt", "Bật tất cả"

### 3. Điều khiển qua Google Assistant
- Dùng Google Assistant trên điện thoại
- Nói: "Hey Google, talk to SmartHomeController"
- Sau đó: "Bật đèn" hoặc "Turn on the LED"

## 🛠️ Development

### Build for production
```bash
npm run build
```

### Test
```bash
npm test
```

### Run tests with coverage
```bash
npm test -- --coverage
```

## 📱 Responsive Design

Giao diện được thiết kế responsive cho nhiều kích thước màn hình:
- Desktop: Grid layout với nhiều cột
- Tablet: 2 cột
- Mobile: 1 cột, full width

## 🎨 Theming

CSS Variables được định nghĩa trong `App.css`:
```css
:root {
  --primary-color: #4CAF50;
  --secondary-color: #2196F3;
  --danger-color: #f44336;
  --dark-bg: #1a1a1a;
  --card-bg: #2d2d2d;
}
```

Bạn có thể custom colors bằng cách thay đổi các biến này.

## 🔧 Troubleshooting

### Web Speech API không hoạt động
- Kiểm tra trình duyệt có hỗ trợ Web Speech API (Chrome, Edge)
- Đảm bảo đang chạy trên HTTPS hoặc localhost
- Cho phép microphone access khi trình duyệt yêu cầu

### Không kết nối được với backend
- Kiểm tra backend đang chạy tại `http://localhost:3000`
- Kiểm tra CORS settings trong backend
- Kiểm tra `REACT_APP_API_URL` trong `.env`

### Thiết bị không cập nhật
- Kiểm tra ESP32 đã kết nối MQTT broker
- Kiểm tra MQTT topics đúng format
- Xem logs trong browser console

## 📚 Dependencies

### Main Dependencies
- `react`: ^18.2.0 - UI framework
- `react-dom`: ^18.2.0 - React DOM rendering

### Dev Dependencies
- `react-scripts`: ^5.0.1 - Build tools

## 🌐 Browser Support

- Chrome/Edge: ✅ Full support (including Web Speech API)
- Firefox: ✅ UI support (Web Speech API limited)
- Safari: ⚠️ UI support (no Web Speech API)

## 📄 License

MIT

## 👨‍💻 Author

TDM University - Year 4, Semester 1 - IoT Project

## 🔗 Related Documentation

- Backend API: `../backend/README.md`
- Google Assistant Setup: `../docs/ACTIONS_ON_GOOGLE_SETUP.md`
- Quick Start Guide: `../QUICKSTART.md`
- Deployment Checklist: `../DEPLOYMENT_CHECKLIST.md`
