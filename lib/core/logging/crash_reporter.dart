import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'logger.dart';
import 'log_event.dart';
import 'log_level.dart';
import 'outputs/memory_log_output.dart';
import 'outputs/remote_log_output.dart';

class CrashReporter {
  static final _logger = Logger.forModule('CrashReporter');
  static MemoryLogOutput? _memoryOutput;
  static RemoteLogOutput? _remoteOutput;
  static bool _isInitialized = false;

  static void initialize({
    String? remoteEndpoint,
    Map<String, String>? remoteHeaders,
    Function(FlutterErrorDetails)? onError,
  }) {
    if (_isInitialized) return;
    _isInitialized = true;

    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
      onError?.call(details);
    };

    // Set up error handling for async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleAsyncError(error, stack);
      return true;
    };

    // Set up isolate error handling
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      _handleIsolateError(errorAndStacktrace[0], errorAndStacktrace[1]);
    }).sendPort);

    // Initialize remote output if endpoint provided
    if (remoteEndpoint != null) {
      _remoteOutput = RemoteLogOutput(
        endpoint: remoteEndpoint,
        headers: remoteHeaders,
        minimumLevel: LogLevel.error,
      );
    }

    _logger.info('Crash reporter initialized');
  }

  static void setMemoryLogOutput(MemoryLogOutput output) {
    _memoryOutput = output;
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    final errorMessage = details.exceptionAsString();
    final stackTrace = details.stack;

    _logger.fatal(
      'Flutter Error: $errorMessage',
      metadata: {
        'library': details.library,
        'context': details.context?.toString(),
        'silent': details.silent,
      },
      error: details.exception,
      stackTrace: stackTrace,
    );

    _sendCrashReport(
      type: 'flutter_error',
      error: errorMessage,
      stackTrace: stackTrace,
      metadata: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  }

  static void _handleAsyncError(Object error, StackTrace stack) {
    _logger.fatal(
      'Async Error: ${error.toString()}',
      metadata: {
        'errorType': error.runtimeType.toString(),
      },
      error: error,
      stackTrace: stack,
    );

    _sendCrashReport(
      type: 'async_error',
      error: error.toString(),
      stackTrace: stack,
      metadata: {
        'errorType': error.runtimeType.toString(),
      },
    );
  }

  static void _handleIsolateError(dynamic error, dynamic stack) {
    _logger.fatal(
      'Isolate Error: ${error.toString()}',
      metadata: {
        'errorType': error.runtimeType.toString(),
        'isolate': Isolate.current.debugName,
      },
      error: error,
      stackTrace: stack is StackTrace ? stack : StackTrace.current,
    );

    _sendCrashReport(
      type: 'isolate_error',
      error: error.toString(),
      stackTrace: stack is StackTrace ? stack : StackTrace.current,
      metadata: {
        'errorType': error.runtimeType.toString(),
        'isolate': Isolate.current.debugName,
      },
    );
  }

  static void reportError({
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    bool fatal = false,
  }) {
    final level = fatal ? LogLevel.fatal : LogLevel.error;
    
    _logger.log(
      level,
      'Reported Error: ${error.toString()}',
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );

    if (fatal) {
      _sendCrashReport(
        type: 'reported_error',
        error: error.toString(),
        stackTrace: stackTrace,
        metadata: metadata,
      );
    }
  }

  static void _sendCrashReport({
    required String type,
    required String error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final report = {
      'type': type,
      'error': error,
      'stackTrace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata,
      'deviceInfo': _getDeviceInfo(),
      'appInfo': _getAppInfo(),
      'recentLogs': _getRecentLogs(),
    };

    // Send to remote if available
    _remoteOutput?.output(LogEvent(
      timestamp: DateTime.now(),
      level: LogLevel.fatal,
      message: 'Crash Report',
      logger: 'CrashReporter',
      metadata: report,
      error: error,
      stackTrace: stackTrace,
    ));

    // Also log locally for debugging
    if (kDebugMode) {
      // ignore: avoid_print
      print('CRASH REPORT: ${jsonEncode(report)}');
    }
  }

  static Map<String, dynamic> _getDeviceInfo() {
    // This should be expanded with actual device info
    return {
      'platform': defaultTargetPlatform.toString(),
      'isPhysicalDevice': !kIsWeb,
      'isDebugMode': kDebugMode,
    };
  }

  static Map<String, dynamic> _getAppInfo() {
    // This should be expanded with actual app info
    return {
      'appName': 'Katomik',
      'buildMode': kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
    };
  }

  static List<String> _getRecentLogs() {
    if (_memoryOutput != null) {
      return _memoryOutput!
          .getFormattedLogs()
          .take(50) // Last 50 logs
          .toList();
    }
    return [];
  }

  static Future<void> dispose() async {
    await _remoteOutput?.dispose();
  }
}