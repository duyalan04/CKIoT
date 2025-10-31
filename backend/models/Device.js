// models/Device.js - Device Model
const pool = require('../config/db');

class Device {
  
  // Lấy tất cả thiết bị
  static async getAll() {
    const result = await pool.query('SELECT * FROM devices ORDER BY id');
    return result.rows;
  }

  // Lấy thiết bị theo ID
  static async getById(id) {
    const result = await pool.query('SELECT * FROM devices WHERE id = $1', [id]);
    return result.rows[0];
  }

  // Lấy thiết bị theo tên
  static async getByName(name) {
    const result = await pool.query(
      'SELECT * FROM devices WHERE LOWER(name) = LOWER($1)', 
      [name]
    );
    return result.rows[0];
  }

  // Cập nhật trạng thái thiết bị
  static async updateState(name, state, speed = null) {
    const query = speed !== null
      ? 'UPDATE devices SET state = $1, speed = $2, last_updated = $3 WHERE LOWER(name) = LOWER($4) RETURNING *'
      : 'UPDATE devices SET state = $1, last_updated = $2 WHERE LOWER(name) = LOWER($3) RETURNING *';
    
    const params = speed !== null
      ? [state, speed, new Date(), name]
      : [state, new Date(), name];
    
    const result = await pool.query(query, params);
    return result.rows[0];
  }

  // Cập nhật tất cả thiết bị
  static async updateAll(state) {
    const result = await pool.query(
      'UPDATE devices SET state = $1, last_updated = $2 RETURNING *',
      [state, new Date()]
    );
    return result.rows;
  }

  // Ghi log hành động
  static async logAction(deviceType, action, value = '') {
    const query = `
      INSERT INTO device_logs (device_type, action, value, timestamp)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const result = await pool.query(query, [
      deviceType,
      action,
      value.toString(),
      new Date()
    ]);
    return result.rows[0];
  }

  // Lấy logs
  static async getLogs(deviceType = null, limit = 50) {
    let query = 'SELECT * FROM device_logs';
    let params = [];
    
    if (deviceType) {
      query += ' WHERE device_type = $1';
      params.push(deviceType);
    }
    
    query += ' ORDER BY timestamp DESC LIMIT $' + (params.length + 1);
    params.push(parseInt(limit));
    
    const result = await pool.query(query, params);
    return result.rows;
  }
}

module.exports = Device;
