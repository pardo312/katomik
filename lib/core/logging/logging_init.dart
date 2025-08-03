import 'package:flutter/foundation.dart';
import 'logging.dart';

class LoggingInit {
  static bool _initialized = false;
  static MemoryLogOutput? _memoryLogOutput;

  static void initialize({
    String? remoteEndpoint,
    Map<String, String>? remoteHeaders,
    bool enableFileLogging = true,
    bool enableCrashReporting = true,
  }) {
    if (_initialized) return;
    _initialized = true;

    // Create memory output for crash reports
    _memoryLogOutput = MemoryLogOutput(maxEvents: 1000);

    // Configure logging based on build mode
    if (kDebugMode) {
      LoggingConfig.configure(
        minimumLevel: LogLevel.debug,
        outputs: [
          ConsoleLogOutput(useColors: true),
          _memoryLogOutput!,
        ],
        enableFileLogging: false,
      );
    } else {
      final outputs = <LogOutput>[
        ConsoleLogOutput(useColors: false, includeTimestamp: false),
        _memoryLogOutput!,
      ];

      if (enableFileLogging && !kIsWeb) {
        outputs.add(FileLogOutput());
      }

      if (remoteEndpoint != null) {
        outputs.add(RemoteLogOutput(
          endpoint: remoteEndpoint,
          headers: remoteHeaders,
          minimumLevel: LogLevel.warning,
        ));
      }

      LoggingConfig.configure(
        minimumLevel: LogLevel.info,
        outputs: outputs,
        blockedModules: {'NetworkLogger'}, // Too verbose for production
      );
    }

    // Initialize crash reporting
    if (enableCrashReporting) {
      CrashReporter.initialize(
        remoteEndpoint: remoteEndpoint,
        remoteHeaders: remoteHeaders,
      );
      CrashReporter.setMemoryLogOutput(_memoryLogOutput!);
    }

    // Log initialization
    final logger = Logger.forModule('App');
    logger.info(
      'Logging system initialized',
      metadata: {
        'debugMode': kDebugMode,
        'crashReporting': enableCrashReporting,
        'fileLogging': enableFileLogging && !kIsWeb,
        'remoteLogging': remoteEndpoint != null,
      },
    );
  }

  static MemoryLogOutput? get memoryLogOutput => _memoryLogOutput;

  static Future<void> dispose() async {
    await Logger.dispose();
    await CrashReporter.dispose();
  }
}