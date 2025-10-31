#include <WiFi.h>
#include <PubSubClient.h>

// === CẤU HÌNH WIFI ===
// const char* WIFI_SSID = "Iphone 16 Pro";        // ← SỬA TÊN WIFI
// const char* WIFI_PASSWORD = "01062004"; // ← SỬA MẬT KHẨU


const char* WIFI_SSID = "VIPVIP";        // ← SỬA TÊN WIFI
const char* WIFI_PASSWORD = "@@thanh12345@@#"; // ← SỬA MẬT KHẨU

// === CẤU HÌNH EMQX (không TLS) ===
const char* MQTT_BROKER = "broker.emqx.io";
const int MQTT_PORT = 1883;

// === CHÂN PHẦN CỨNG ===
#define LED_PIN  18
#define FAN_IN1  13
#define FAN_IN2  12

// === TOPIC MQTT ===
const char* LED_SET_TOPIC = "home/led/set";
const char* FAN_SET_TOPIC = "home/fan/set";

// === BIẾN ===
WiFiClient espClient;
PubSubClient client(espClient);

void setFan(bool on) {
  if (on) {
    digitalWrite(FAN_IN1, HIGH);
    digitalWrite(FAN_IN2, LOW);
  } else {
    digitalWrite(FAN_IN1, LOW);
    digitalWrite(FAN_IN2, LOW); // ⚠️ BẮT BUỘC: TẮT CẢ HAI CHÂN
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String msg = "";
  for (int i = 0; i < length; i++) msg += (char)payload[i];
  msg.trim();

  if (String(topic) == LED_SET_TOPIC) {
    bool state = (msg == "ON" || msg == "true");
    digitalWrite(LED_PIN, state ? HIGH : LOW);
    client.publish("home/led/state", state ? "ON" : "OFF");
    Serial.println("LED: " + String(state ? "ON" : "OFF"));
  }
  else if (String(topic) == FAN_SET_TOPIC) {
    bool state = (msg == "ON" || msg == "true");
    setFan(state);
    client.publish("home/fan/state", state ? "ON" : "OFF");
    Serial.println("FAN: " + String(state ? "ON" : "OFF"));
  }
}

void connectWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Kết nối WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi OK!");
}

void connectMQTT() {
  while (!client.connected()) {
    Serial.print("Kết nối MQTT...");
    
    // Tạo unique ClientID cho ESP32 (dùng MAC address)
    String clientId = "ESP32_" + String(ESP.getEfuseMac(), HEX);
    
    if (client.connect(clientId.c_str())) { // Không cần user/pass
      Serial.println(" ✅");
      Serial.println("Client ID: " + clientId);
      client.subscribe(LED_SET_TOPIC);
      client.subscribe(FAN_SET_TOPIC);
    } else {
      Serial.print(" ❌ (lỗi: ");
      Serial.print(client.state());
      Serial.println(") Thử lại sau 3s");
      delay(3000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(FAN_IN1, OUTPUT);
  pinMode(FAN_IN2, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  setFan(false);

  connectWiFi();
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(mqttCallback);
}

void loop() {
  if (!client.connected()) connectMQTT();
  client.loop();
}