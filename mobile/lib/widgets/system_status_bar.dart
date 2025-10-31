// lib/widgets/system_status_bar.dart - System Status Display
import 'package:flutter/material.dart';
import '../models/device.dart';

class SystemStatusBar extends StatelessWidget {
  final SystemStatus? status;
  final bool loading;

  const SystemStatusBar({super.key, this.status, this.loading = false});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Trạng thái hệ thống',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  'Server',
                  status?.server ?? 'unknown',
                  Icons.dns,
                ),
                _buildStatusItem(
                  'Database',
                  status?.database ?? 'unknown',
                  Icons.storage,
                ),
                _buildStatusItem(
                  'MQTT',
                  status?.mqtt ?? 'unknown',
                  Icons.cloud,
                ),
                _buildStatusItem(
                  'ESP32',
                  status?.mqtt == 'connected' ? 'connected' : 'checking',
                  Icons.memory,
                ),
              ],
            ),
            if (status?.timestamp != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Cập nhật: ${status!.timestamp}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String state, IconData icon) {
    Color statusColor;
    String statusIcon;

    if (state == 'connected' || state == 'running') {
      statusColor = Colors.green;
      statusIcon = '🟢';
    } else if (state == 'disconnected') {
      statusColor = Colors.red;
      statusIcon = '🔴';
    } else {
      statusColor = Colors.orange;
      statusIcon = '🟡';
    }

    return Column(
      children: [
        Icon(icon, color: statusColor, size: 32),
        const SizedBox(height: 4),
        Text(statusIcon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
