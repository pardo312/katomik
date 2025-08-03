import 'package:flutter/foundation.dart';
import 'log_event.dart';
import 'log_level.dart';

abstract class LogFilter {
  bool shouldLog(LogEvent event);
}

class LevelLogFilter extends LogFilter {
  final LogLevel minimumLevel;

  LevelLogFilter({required this.minimumLevel});

  @override
  bool shouldLog(LogEvent event) {
    return event.level.shouldLog(minimumLevel);
  }
}

class DebugLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode;
  }
}

class ProductionLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return !kDebugMode && event.level.value >= LogLevel.warning.value;
  }
}

class ModuleLogFilter extends LogFilter {
  final Set<String> allowedModules;
  final Set<String> blockedModules;

  ModuleLogFilter({
    Set<String>? allowedModules,
    Set<String>? blockedModules,
  })  : allowedModules = allowedModules ?? {},
        blockedModules = blockedModules ?? {};

  @override
  bool shouldLog(LogEvent event) {
    if (blockedModules.contains(event.logger)) {
      return false;
    }
    if (allowedModules.isEmpty) {
      return true;
    }
    return allowedModules.contains(event.logger);
  }
}

class CompositeLogFilter extends LogFilter {
  final List<LogFilter> filters;
  final bool requireAll;

  CompositeLogFilter({
    required this.filters,
    this.requireAll = true,
  });

  @override
  bool shouldLog(LogEvent event) {
    if (requireAll) {
      return filters.every((filter) => filter.shouldLog(event));
    } else {
      return filters.any((filter) => filter.shouldLog(event));
    }
  }
}