-- PostgreSQL schema for Smart Home project (optimized for ESP32 + Google Assistant)

-- Devices table
CREATE TABLE IF NOT EXISTS devices (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,  -- 'led', 'fan'
  type VARCHAR(50) NOT NULL,         -- 'led', 'fan'
  state BOOLEAN DEFAULT false,       -- true = ON, false = OFF
  description TEXT,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Device logs table
CREATE TABLE IF NOT EXISTS device_logs (
  id SERIAL PRIMARY KEY,
  device_name VARCHAR(50) NOT NULL,  -- 'led', 'fan'
  action VARCHAR(10) NOT NULL,       -- 'ON', 'OFF'
  triggered_by VARCHAR(20) DEFAULT 'manual', -- 'google', 'web', 'flutter', 'schedule'
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table (for future)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Schedules (optional, keep if you plan to implement)
CREATE TABLE IF NOT EXISTS schedules (
  id SERIAL PRIMARY KEY,
  device_name VARCHAR(50) NOT NULL,  -- 'led', 'fan'
  action VARCHAR(10) NOT NULL,       -- 'ON', 'OFF'
  schedule_time TIME NOT NULL,
  days_of_week INTEGER[],            -- 0=Sunday, 1=Monday, ..., 6=Saturday
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default devices
INSERT INTO devices (name, type, description) VALUES
  ('led', 'led', 'LED on GPIO 18'),
  ('fan', 'fan', 'DC Fan 3V via L298N')
ON CONFLICT (name) DO NOTHING;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_device_logs_timestamp ON device_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_device_logs_device_name ON device_logs(device_name);
CREATE INDEX IF NOT EXISTS idx_devices_name ON devices(name);

-- View: Recent status
CREATE OR REPLACE VIEW recent_device_status AS
SELECT 
  d.name,
  d.type,
  d.state,
  d.last_updated,
  (
    SELECT COUNT(*) 
    FROM device_logs dl 
    WHERE dl.device_name = d.name 
    AND dl.timestamp > NOW() - INTERVAL '24 hours'
  ) AS actions_today
FROM devices d;