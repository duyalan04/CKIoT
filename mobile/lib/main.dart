import 'package:flutter/material.dart';
import 'dart:async';
import 'models/device.dart';
import 'services/api_service.dart';
import 'widgets/device_card.dart';
import 'widgets/system_status_bar.dart';
import 'widgets/voice_control_button.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(elevation: 2),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> _devices = [];
  SystemStatus? _systemStatus;
  bool _loading = true;
  bool _hasError = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh mỗi 5 giây
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _hasError = false;
      });
    }

    try {
      final devices = await ApiService.getDevices();
      final status = await ApiService.getSystemStatus();

      if (mounted) {
        setState(() {
          _devices = devices;
          _systemStatus = status;
          _loading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
      if (!silent) {
        _showError('Không thể kết nối đến server');
      }
    }
  }

  Future<void> _controlLED(String state) async {
    final success = await ApiService.controlLED(state);
    if (success) {
      _loadData(silent: true);
    } else {
      _showError('Lỗi khi điều khiển LED');
    }
  }

  Future<void> _controlFan(String state, {int? speed}) async {
    final currentFan = _devices.firstWhere(
      (d) => d.type == 'fan',
      orElse: () => Device(
        id: 0,
        name: 'Fan',
        type: 'fan',
        state: 'off',
        speed: 255,
        lastUpdated: DateTime.now(),
      ),
    );

    final fanSpeed = speed ?? (state == 'on' ? (currentFan.speed ?? 255) : 0);
    final success = await ApiService.controlFan(state, speed: fanSpeed);

    if (success) {
      _loadData(silent: true);
    } else {
      _showError('Lỗi khi điều khiển quạt');
    }
  }

  Future<void> _handleVoiceCommand(String device, String action) async {
    try {
      if (device == 'led') {
        await _controlLED(action);
      } else if (device == 'fan') {
        await _controlFan(action);
      } else if (device == 'all') {
        final success = await ApiService.controlAll(action);
        if (success) {
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Đã ${action == 'on' ? 'bật' : 'tắt'} tất cả thiết bị',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          _showError('Lỗi khi điều khiển tất cả thiết bị');
        }
      }
    } catch (e) {
      _showError('Lỗi khi xử lý lệnh giọng nói');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      '🏠 Smart Home',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điều khiển thiết bị IoT với ESP32',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => _loadData(),
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Error Banner
                              if (_hasError)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.red),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '⚠️ Không thể kết nối đến server',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // System Status
                              SystemStatusBar(
                                status: _systemStatus,
                                loading: _loading,
                              ),
                              const SizedBox(height: 16),

                              // Devices Section
                              const Text(
                                '📱 Thiết bị',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Device Cards
                              ..._devices.map((device) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DeviceCard(
                                    device: device,
                                    onToggle: () {
                                      final newState = device.isOn
                                          ? 'off'
                                          : 'on';
                                      if (device.type == 'led') {
                                        _controlLED(newState);
                                      } else if (device.type == 'fan') {
                                        _controlFan(newState);
                                      }
                                    },
                                  ),
                                );
                              }),

                              // Voice Control
                              const SizedBox(height: 8),
                              VoiceControlButton(
                                onCommand: _handleVoiceCommand,
                              ),
                              const SizedBox(height: 20),

                              // Footer
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '© 2025 Smart Home Project',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Create By Zuy',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
