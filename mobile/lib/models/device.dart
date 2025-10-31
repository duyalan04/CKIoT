// lib/models/device.dart - Device Model
class Device {
  final int id;
  final String name;
  final String type;
  final String state;
  final int? speed;
  final DateTime lastUpdated;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    this.speed,
    required this.lastUpdated,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      state: json['state'],
      speed: json['speed'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  bool get isOn => state == 'on';
}

class SystemStatus {
  final String server;
  final String database;
  final String mqtt;
  final String timestamp;

  SystemStatus({
    required this.server,
    required this.database,
    required this.mqtt,
    required this.timestamp,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      server: json['server'] ?? 'unknown',
      database: json['database'] ?? 'unknown',
      mqtt: json['mqtt'] ?? 'unknown',
      timestamp: json['timestamp'] ?? '',
    );
  }

  bool get isHealthy =>
      server == 'running' &&
      (database == 'connected' || database == 'running') &&
      mqtt == 'connected';
}
