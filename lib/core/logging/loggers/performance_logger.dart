import 'package:flutter/foundation.dart';
import '../logger.dart';
import '../log_level.dart';

class PerformanceLogger {
  static final _logger = Logger.forModule('Performance');
  static final Map<String, Stopwatch> _activeTimers = {};

  static void startTimer(String operation) {
    _activeTimers[operation] = Stopwatch()..start();
    _logger.verbose(
      'Timer started: $operation',
      metadata: {'operation': operation},
    );
  }

  static void endTimer(String operation, {Map<String, dynamic>? metadata}) {
    final stopwatch = _activeTimers.remove(operation);
    if (stopwatch == null) {
      _logger.warning('Timer not found: $operation');
      return;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    
    final level = duration > 1000 ? LogLevel.warning : LogLevel.debug;
    
    _logger.log(
      level,
      'Operation completed: $operation',
      metadata: {
        'operation': operation,
        'duration_ms': duration,
        if (metadata != null) ...metadata,
      },
    );
  }

  static void logScreenLoad({
    required String screenName,
    required Duration loadTime,
    Map<String, dynamic>? metadata,
  }) {
    final level = loadTime.inMilliseconds > 500 ? LogLevel.warning : LogLevel.debug;
    
    _logger.log(
      level,
      'Screen loaded: $screenName',
      metadata: {
        'screen': screenName,
        'duration_ms': loadTime.inMilliseconds,
        if (metadata != null) ...metadata,
      },
    );
  }

  static void logWidgetBuild({
    required String widgetName,
    required Duration buildTime,
    int? itemCount,
  }) {
    if (buildTime.inMilliseconds > 16) { // More than one frame (60fps)
      _logger.warning(
        'Slow widget build: $widgetName',
        metadata: {
          'widget': widgetName,
          'duration_ms': buildTime.inMilliseconds,
          if (itemCount != null) 'itemCount': itemCount,
        },
      );
    } else if (kDebugMode) {
      _logger.verbose(
        'Widget build: $widgetName',
        metadata: {
          'widget': widgetName,
          'duration_ms': buildTime.inMilliseconds,
          if (itemCount != null) 'itemCount': itemCount,
        },
      );
    }
  }

  static void logDatabaseOperation({
    required String operation,
    required Duration duration,
    String? table,
    int? rowCount,
  }) {
    final level = duration.inMilliseconds > 100 ? LogLevel.warning : LogLevel.debug;
    
    _logger.log(
      level,
      'Database operation: $operation',
      metadata: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        if (table != null) 'table': table,
        if (rowCount != null) 'rowCount': rowCount,
      },
    );
  }

  static void logMemoryUsage() {
    if (!kDebugMode) return;
    
    // This is a simplified version. In production, you might want to use
    // more sophisticated memory monitoring tools
    _logger.debug(
      'Memory usage check',
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static void logFrameDrop({
    required int droppedFrames,
    String? context,
  }) {
    _logger.warning(
      'Frame drop detected',
      metadata: {
        'droppedFrames': droppedFrames,
        if (context != null) 'context': context,
      },
    );
  }

  static void logCacheHit({
    required String cacheType,
    required String key,
    required bool hit,
  }) {
    _logger.verbose(
      hit ? 'Cache hit' : 'Cache miss',
      metadata: {
        'cacheType': cacheType,
        'key': key,
        'hit': hit,
      },
    );
  }

  static void logSlowOperation({
    required String operation,
    required Duration duration,
    required Duration threshold,
    Map<String, dynamic>? metadata,
  }) {
    if (duration > threshold) {
      _logger.warning(
        'Slow operation detected: $operation',
        metadata: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          'threshold_ms': threshold.inMilliseconds,
          if (metadata != null) ...metadata,
        },
      );
    }
  }
}