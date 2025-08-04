import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? context;
  final Map<String, dynamic>? data;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.context,
    this.data,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'message': message,
        'context': context,
        'data': data,
        'error': error?.toString(),
        'stackTrace': stackTrace?.toString(),
      };
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  static const bool _enableLogging = kDebugMode;
  static const int _maxLogEntries = 500;
  
  final List<LogEntry> _logHistory = [];
  String _context = 'App';

  void setContext(String context) {
    _context = context;
  }

  void debug(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, data: data);
  }

  void info(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, data: data);
  }

  void warning(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, data: data);
  }

  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, data: data);
  }

  void logPerformance(String operation, int durationMs, {Map<String, dynamic>? data}) {
    final performanceData = {
      'operation': operation,
      'duration_ms': durationMs,
      'slow': durationMs > 1000,
      ...?data,
    };

    if (durationMs > 1000) {
      warning('Slow operation: $operation took ${durationMs}ms', data: performanceData);
    } else {
      debug('Operation completed: $operation in ${durationMs}ms', data: performanceData);
    }
  }

  void logApiCall(String method, String endpoint, {Map<String, dynamic>? variables, int? statusCode, Object? error}) {
    final apiData = {
      'method': method,
      'endpoint': endpoint,
      'variables': variables,
      'status_code': statusCode,
    };

    if (error != null) {
      this.error('API call failed: $method $endpoint', error: error, data: apiData);
    } else {
      info('API call: $method $endpoint', data: apiData);
    }
  }

  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enableLogging) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      context: _context,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );

    _addToHistory(entry);
    _outputLog(entry);
  }

  void _addToHistory(LogEntry entry) {
    _logHistory.add(entry);
    if (_logHistory.length > _maxLogEntries) {
      _logHistory.removeAt(0);
    }
  }

  void _outputLog(LogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    final levelStr = entry.level.name.toUpperCase().padRight(7);
    final contextStr = '[${entry.context}]';
    final message = '$timestamp $levelStr $contextStr ${entry.message}';

    // Console output
    switch (entry.level) {
      case LogLevel.debug:
        developer.log(
          message,
          name: entry.context ?? 'App',
          level: 500,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.info:
        developer.log(
          message,
          name: entry.context ?? 'App',
          level: 800,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.warning:
        developer.log(
          message,
          name: entry.context ?? 'App',
          level: 900,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.error:
        developer.log(
          message,
          name: entry.context ?? 'App',
          level: 1000,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
    }

    // Additional data logging
    if (entry.data != null && entry.data!.isNotEmpty) {
      developer.log(
        'Data: ${entry.data}',
        name: entry.context ?? 'App',
        level: 500,
      );
    }
  }

  List<LogEntry> getHistory({LogLevel? minLevel}) {
    if (minLevel == null) {
      return List.unmodifiable(_logHistory);
    }

    return _logHistory
        .where((entry) => entry.level.index >= minLevel.index)
        .toList();
  }

  void clearHistory() {
    _logHistory.clear();
  }

  Map<String, dynamic> getStats() {
    final stats = <String, int>{};
    for (final entry in _logHistory) {
      final key = entry.level.name;
      stats[key] = (stats[key] ?? 0) + 1;
    }
    return stats;
  }
}

// Convenience singleton instance
final logger = LoggerService();