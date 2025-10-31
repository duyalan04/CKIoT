// lib/widgets/device_card.dart - Device Control Card
import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onToggle;

  const DeviceCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isFan = device.type == 'fan';
    final bool isOn = device.isOn;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isOn
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.grey.shade300, Colors.grey.shade500],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isOn ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOn ? Colors.white : Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOn ? '🟢 BẬT' : '🔴 TẮT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOn ? Colors.green : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Icon
              Center(
                child: Icon(
                  isFan ? Icons.air : Icons.lightbulb,
                  size: 80,
                  color: isOn ? Colors.white : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Toggle Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOn ? Colors.red.shade600 : Colors.white,
                    foregroundColor: isOn
                        ? Colors.white
                        : Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isOn ? Icons.power_settings_new : Icons.power),
                      const SizedBox(width: 8),
                      Text(
                        isOn ? 'TẮT' : 'BẬT',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Device Info
              const SizedBox(height: 16),
              Divider(color: isOn ? Colors.white30 : Colors.black26),
              const SizedBox(height: 8),
              Text(
                'Loại: ${device.type}',
                style: TextStyle(color: isOn ? Colors.white70 : Colors.black54),
              ),
              Text(
                'Cập nhật: ${_formatDateTime(device.lastUpdated)}',
                style: TextStyle(
                  color: isOn ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
