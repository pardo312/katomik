enum LogLevel {
  verbose(0),
  debug(1),
  info(2),
  warning(3),
  error(4),
  fatal(5);

  final int value;
  const LogLevel(this.value);

  bool shouldLog(LogLevel minimumLevel) {
    return value >= minimumLevel.value;
  }

  String get prefix {
    switch (this) {
      case LogLevel.verbose:
        return '[V]';
      case LogLevel.debug:
        return '[D]';
      case LogLevel.info:
        return '[I]';
      case LogLevel.warning:
        return '[W]';
      case LogLevel.error:
        return '[E]';
      case LogLevel.fatal:
        return '[F]';
    }
  }

  String get emoji {
    switch (this) {
      case LogLevel.verbose:
        return '🔍';
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }
}