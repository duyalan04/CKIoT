// lib/widgets/voice_control_button.dart - Voice Control
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceControlButton extends StatefulWidget {
  final Function(String device, String action) onCommand;

  const VoiceControlButton({super.key, required this.onCommand});

  @override
  State<VoiceControlButton> createState() => _VoiceControlButtonState();
}

class _VoiceControlButtonState extends State<VoiceControlButton>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcript = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền microphone để sử dụng tính năng này'),
          ),
        );
      }
    }
  }

  Future<void> _startListening() async {
    await _requestMicrophonePermission();

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${error.errorMsg}')));
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _transcript = '';
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcript = result.recognizedWords;
          });
          if (result.finalResult) {
            _processCommand(_transcript);
          }
        },
        localeId: 'vi_VN', // Tiếng Việt
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _processCommand(String command) {
    final lowerCommand = command.toLowerCase();

    if (lowerCommand.contains('bật đèn') || lowerCommand.contains('mở đèn')) {
      widget.onCommand('led', 'on');
      _showCommandFeedback('Đã bật đèn LED');
    } else if (lowerCommand.contains('tắt đèn')) {
      widget.onCommand('led', 'off');
      _showCommandFeedback('Đã tắt đèn LED');
    } else if (lowerCommand.contains('bật quạt') ||
        lowerCommand.contains('mở quạt')) {
      widget.onCommand('fan', 'on');
      _showCommandFeedback('Đã bật quạt');
    } else if (lowerCommand.contains('tắt quạt')) {
      widget.onCommand('fan', 'off');
      _showCommandFeedback('Đã tắt quạt');
    } else if (lowerCommand.contains('bật tất cả')) {
      widget.onCommand('all', 'on');
      _showCommandFeedback('Đã bật tất cả thiết bị');
    } else if (lowerCommand.contains('tắt tất cả')) {
      widget.onCommand('all', 'off');
      _showCommandFeedback('Đã tắt tất cả thiết bị');
    } else {
      _showCommandFeedback('Lệnh không được nhận dạng');
    }
  }

  void _showCommandFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showVoiceCommandsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.blue),
            SizedBox(width: 8),
            Text('Các lệnh giọng nói'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCommandItem('🔆 "Bật đèn" / "Mở đèn"'),
              _buildCommandItem('💡 "Tắt đèn"'),
              _buildCommandItem('💨 "Bật quạt" / "Mở quạt"'),
              _buildCommandItem('🌀 "Tắt quạt"'),
              _buildCommandItem('✨ "Bật tất cả"'),
              _buildCommandItem('⚫ "Tắt tất cả"'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '💡 Tip: Bạn cũng có thể dùng Google Assistant:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('"Hey Google, talk to SmartHomeController"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandItem(String command) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_right, size: 16),
          const SizedBox(width: 4),
          Expanded(child: Text(command)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.record_voice_over, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Điều khiển giọng nói',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: _showVoiceCommandsDialog,
                  tooltip: 'Xem danh sách lệnh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [Colors.red.shade400, Colors.red.shade700]
                            : [Colors.blue.shade400, Colors.blue.shade700],
                      ),
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(
                                  0.5 * _animationController.value,
                                ),
                                blurRadius: 20,
                                spreadRadius: 10 * _animationController.value,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isListening ? 'Đang nghe...' : 'Nhấn để nói',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isListening ? Colors.red : Colors.blue,
              ),
            ),
            if (_transcript.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn nói: "$_transcript"',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
