# Smart Home Backend

Backend Node.js cho dự án Smart Home với kiến trúc MVC.

## 📁 Cấu trúc thư mục

```
backend/
├── config/                      # Configuration files
│   ├── db.js                   # PostgreSQL connection
│   └── mqtt.js                 # MQTT client setup
│
├── controllers/                # Controllers (Business logic)
│   ├── deviceController.js     # Device control logic
│   └── googleAssistantController.js  # Google Assistant webhook handler
│
├── models/                     # Database models
│   └── Device.js              # Device model with CRUD operations
│
├── routes/                     # API routes
│   ├── api.js                 # REST API routes
│   └── dialogflow.js          # Google Assistant webhook route
│
├── services/                   # Business services
│   └── mqttService.js         # MQTT publish/subscribe service
│
├── .env                        # Environment variables
├── package.json               # Dependencies
└── server.js                  # Application entry point
```

## 🚀 Cài đặt

```bash
# 1. Install dependencies
npm install

# 2. Tạo file .env từ .env.example
copy .env.example .env

# 3. Cấu hình .env với thông tin của bạn
# - Database credentials
# - MQTT broker URL
# - Server port

# 4. Khởi động server
npm start

# Hoặc development mode (auto-restart)
npm run dev
```

## 🔌 API Endpoints

### REST API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api` | API health check |
| GET | `/api/devices` | Lấy danh sách thiết bị |
| GET | `/api/devices/:id` | Lấy thông tin thiết bị theo ID |
| POST | `/api/led` | Điều khiển LED |
| POST | `/api/fan` | Điều khiển quạt |
| GET | `/api/logs` | Lấy logs thiết bị |
| GET | `/api/status` | Lấy trạng thái hệ thống |

### Google Assistant Webhook

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/google-assistant` | Webhook cho Dialogflow |

## 📝 Ví dụ sử dụng

### Điều khiển LED

```bash
# Bật LED
curl -X POST http://localhost:3000/api/led \
  -H "Content-Type: application/json" \
  -d '{"state":"on"}'

# Tắt LED
curl -X POST http://localhost:3000/api/led \
  -H "Content-Type: application/json" \
  -d '{"state":"off"}'
```

### Điều khiển Quạt

```bash
# Bật quạt với tốc độ 200
curl -X POST http://localhost:3000/api/fan \
  -H "Content-Type: application/json" \
  -d '{"state":"on","speed":200}'

# Tắt quạt
curl -X POST http://localhost:3000/api/fan \
  -H "Content-Type: application/json" \
  -d '{"state":"off"}'
```

### Lấy danh sách thiết bị

```bash
curl http://localhost:3000/api/devices
```

### Lấy logs

```bash
# Tất cả logs
curl http://localhost:3000/api/logs

# Logs của LED
curl http://localhost:3000/api/logs?device=led

# Giới hạn 20 logs
curl http://localhost:3000/api/logs?limit=20
```

## 🏗️ Kiến trúc

### Flow điều khiển thiết bị

```
Client Request → Routes → Controller → Service → MQTT Broker → ESP32
                              ↓
                           Model → Database (Log)
```

### Flow Google Assistant

```
Google Assistant → Dialogflow → Webhook → Controller → Service → MQTT
                                              ↓
                                           Model → Database
```

## 📦 Dependencies

- **express**: Web framework
- **pg**: PostgreSQL client
- **mqtt**: MQTT protocol client
- **dotenv**: Environment variables
- **cors**: Cross-Origin Resource Sharing
- **body-parser**: Request body parsing
- **moment**: Date/time formatting

## 🔧 Configuration

File `.env`:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=smarthome
DB_USER=postgres
DB_PASSWORD=your_password

# MQTT
MQTT_BROKER=mqtt://broker.hivemq.com
MQTT_CLIENT_ID=smart-home-backend
MQTT_TOPIC_FAN=home/fan
MQTT_TOPIC_LED=home/led
MQTT_TOPIC_STATUS=home/status

# Server
PORT=3000
NODE_ENV=development
```

## 🧪 Testing

```bash
# Test với curl
curl http://localhost:3000/api/devices

# Test điều khiển LED
curl -X POST http://localhost:3000/api/led \
  -H "Content-Type: application/json" \
  -d '{"state":"on"}'
```

## 📊 Database Schema

```sql
-- Devices table
CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(20) NOT NULL,
    state VARCHAR(10) DEFAULT 'off',
    speed INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Device logs table
CREATE TABLE device_logs (
    id SERIAL PRIMARY KEY,
    device_type VARCHAR(20) NOT NULL,
    action VARCHAR(50) NOT NULL,
    value VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🐛 Troubleshooting

### Database connection error
```bash
# Kiểm tra PostgreSQL đang chạy
psql -U postgres -d smarthome -c "SELECT NOW();"
```

### MQTT connection error
```bash
# Kiểm tra MQTT broker
# Sử dụng MQTTX client để test
```

### Port already in use
```bash
# Đổi PORT trong file .env
PORT=3001
```

## 📚 Tài liệu tham khảo

- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MQTT Protocol](https://mqtt.org/)
- [Dialogflow Webhook](https://cloud.google.com/dialogflow/es/docs/fulfillment-webhook)
