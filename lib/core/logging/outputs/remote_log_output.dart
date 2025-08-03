import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../log_event.dart';
import '../log_level.dart';
import '../log_output.dart';

class RemoteLogOutput extends LogOutput {
  final String endpoint;
  final Map<String, String> headers;
  final int batchSize;
  final Duration batchInterval;
  final LogLevel minimumLevel;
  final Queue<LogEvent> _buffer = Queue<LogEvent>();
  Timer? _batchTimer;
  bool _isSending = false;
  
  RemoteLogOutput({
    required this.endpoint,
    Map<String, String>? headers,
    this.batchSize = 50,
    this.batchInterval = const Duration(seconds: 30),
    this.minimumLevel = LogLevel.warning,
  }) : headers = headers ?? {} {
    _startBatchTimer();
  }

  @override
  void output(LogEvent event) {
    if (!event.level.shouldLog(minimumLevel)) {
      return;
    }
    
    _buffer.add(event);
    
    if (_buffer.length >= batchSize) {
      _sendBatch();
    }
  }

  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(batchInterval, (_) {
      if (_buffer.isNotEmpty) {
        _sendBatch();
      }
    });
  }

  Future<void> _sendBatch() async {
    if (_isSending || _buffer.isEmpty) return;
    
    _isSending = true;
    final batch = <LogEvent>[];
    
    while (_buffer.isNotEmpty && batch.length < batchSize) {
      batch.add(_buffer.removeFirst());
    }
    
    try {
      final payload = {
        'logs': batch.map((e) => e.toJson()).toList(),
        'batchId': DateTime.now().millisecondsSinceEpoch.toString(),
        'app': 'katomik',
        'platform': _getPlatform(),
      };
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        // Re-add failed logs to buffer
        _buffer.addAll(batch);
      }
    } catch (e) {
      // Re-add failed logs to buffer
      _buffer.addAll(batch);
      // ignore: avoid_print
      print('Failed to send logs to remote: $e');
    } finally {
      _isSending = false;
    }
  }

  String _getPlatform() {
    // This should be replaced with actual platform detection
    return 'flutter';
  }

  @override
  Future<void> dispose() async {
    _batchTimer?.cancel();
    if (_buffer.isNotEmpty) {
      await _sendBatch();
    }
  }
}