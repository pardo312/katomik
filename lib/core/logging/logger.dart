import 'dart:async';
import 'package:flutter/foundation.dart';
import 'log_event.dart';
import 'log_filter.dart';
import 'log_level.dart';
import 'log_output.dart';

class Logger {
  final String name;
  final LogFilter filter;
  final LogOutput output;
  final Map<String, dynamic> defaultMetadata;
  String? _correlationId;

  Logger({
    required this.name,
    required this.filter,
    required this.output,
    Map<String, dynamic>? defaultMetadata,
  }) : defaultMetadata = defaultMetadata ?? {};

  static final Map<String, Logger> _loggers = {};
  static LogFilter _defaultFilter = CompositeLogFilter(
    filters: [
      LevelLogFilter(
        minimumLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
      ),
      DebugLogFilter(),
    ],
  );
  static LogOutput _defaultOutput = ConsoleLogOutput();

  static void setDefaultFilter(LogFilter filter) {
    _defaultFilter = filter;
  }

  static void setDefaultOutput(LogOutput output) {
    _defaultOutput = output;
  }

  factory Logger.forModule(String module) {
    return _loggers.putIfAbsent(
      module,
      () => Logger(
        name: module,
        filter: _defaultFilter,
        output: _defaultOutput,
      ),
    );
  }

  void setCorrelationId(String? id) {
    _correlationId = id;
  }

  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final event = LogEvent(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      logger: name,
      metadata: {
        ...defaultMetadata,
        if (metadata != null) ...metadata,
      },
      error: error,
      stackTrace: stackTrace,
      correlationId: _correlationId,
    );

    if (filter.shouldLog(event)) {
      output.output(event);
    }
  }

  void verbose(String message, {Map<String, dynamic>? metadata}) {
    log(LogLevel.verbose, message, metadata: metadata);
  }

  void debug(String message, {Map<String, dynamic>? metadata}) {
    log(LogLevel.debug, message, metadata: metadata);
  }

  void info(String message, {Map<String, dynamic>? metadata}) {
    log(LogLevel.info, message, metadata: metadata);
  }

  void warning(
    String message, {
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.warning,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    String message, {
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.error,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void fatal(
    String message, {
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.fatal,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  T time<T>(String operation, T Function() action, {Map<String, dynamic>? metadata}) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = action();
      stopwatch.stop();
      info(
        'Operation completed: $operation',
        metadata: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          if (metadata != null) ...metadata,
        },
      );
      return result;
    } catch (e, stack) {
      stopwatch.stop();
      error(
        'Operation failed: $operation',
        metadata: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          if (metadata != null) ...metadata,
        },
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<T> timeAsync<T>(
    String operation,
    Future<T> Function() action, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      info(
        'Async operation completed: $operation',
        metadata: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          if (metadata != null) ...metadata,
        },
      );
      return result;
    } catch (e, stack) {
      stopwatch.stop();
      error(
        'Async operation failed: $operation',
        metadata: {
          'duration_ms': stopwatch.elapsedMilliseconds,
          if (metadata != null) ...metadata,
        },
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  static Future<void> dispose() async {
    await _defaultOutput.dispose();
  }
}