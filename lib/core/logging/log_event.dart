import 'log_level.dart';

class LogEvent {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String logger;
  final Map<String, dynamic>? metadata;
  final Object? error;
  final StackTrace? stackTrace;
  final String? correlationId;

  LogEvent({
    required this.timestamp,
    required this.level,
    required this.message,
    required this.logger,
    this.metadata,
    this.error,
    this.stackTrace,
    this.correlationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'logger': logger,
      'metadata': metadata,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'correlationId': correlationId,
    };
  }

  String toFormattedString() {
    final buffer = StringBuffer();
    buffer.write('${timestamp.toIso8601String()} ');
    buffer.write('${level.prefix} ');
    buffer.write('[$logger] ');
    buffer.write(message);
    
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(metadata);
    }
    
    if (error != null) {
      buffer.write('\n  Error: $error');
    }
    
    if (stackTrace != null) {
      buffer.write('\n  Stack: $stackTrace');
    }
    
    return buffer.toString();
  }
}