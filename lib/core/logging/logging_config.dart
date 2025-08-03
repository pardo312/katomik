import 'package:flutter/foundation.dart';
import 'log_filter.dart';
import 'log_level.dart';
import 'log_output.dart';
import 'logger.dart';
import 'outputs/memory_log_output.dart';
import 'outputs/file_log_output.dart';

class LoggingConfig {
  static final LoggingConfig _instance = LoggingConfig._internal();
  factory LoggingConfig() => _instance;
  LoggingConfig._internal();

  static void configure({
    LogLevel? minimumLevel,
    List<LogOutput>? outputs,
    List<LogFilter>? filters,
    bool enableFileLogging = false,
    bool enableMemoryLogging = true,
    int memoryLogLimit = 1000,
    Set<String>? allowedModules,
    Set<String>? blockedModules,
  }) {
    final outputList = <LogOutput>[];
    
    if (outputs != null) {
      outputList.addAll(outputs);
    } else {
      outputList.add(ConsoleLogOutput());
      
      if (enableMemoryLogging) {
        outputList.add(MemoryLogOutput(maxEvents: memoryLogLimit));
      }
      
      if (enableFileLogging && !kIsWeb) {
        outputList.add(FileLogOutput());
      }
    }
    
    final filterList = <LogFilter>[];
    
    if (filters != null) {
      filterList.addAll(filters);
    } else {
      filterList.add(
        LevelLogFilter(
          minimumLevel: minimumLevel ?? 
            (kDebugMode ? LogLevel.debug : LogLevel.info),
        ),
      );
      
      if (!kDebugMode) {
        filterList.add(ProductionLogFilter());
      }
      
      if (allowedModules != null || blockedModules != null) {
        filterList.add(
          ModuleLogFilter(
            allowedModules: allowedModules,
            blockedModules: blockedModules,
          ),
        );
      }
    }
    
    Logger.setDefaultOutput(
      outputList.length == 1 
        ? outputList.first 
        : MultiLogOutput(outputList),
    );
    
    Logger.setDefaultFilter(
      filterList.length == 1 
        ? filterList.first 
        : CompositeLogFilter(filters: filterList),
    );
  }

  static void configureForDebug() {
    configure(
      minimumLevel: LogLevel.verbose,
      enableMemoryLogging: true,
      enableFileLogging: false,
    );
  }

  static void configureForRelease() {
    configure(
      minimumLevel: LogLevel.info,
      enableMemoryLogging: true,
      enableFileLogging: true,
      blockedModules: {'NetworkLogger'}, // Block verbose network logs in release
    );
  }

  static void configureForTesting() {
    configure(
      minimumLevel: LogLevel.debug,
      enableMemoryLogging: true,
      enableFileLogging: false,
      outputs: [MemoryLogOutput()], // Only memory output for tests
    );
  }
}