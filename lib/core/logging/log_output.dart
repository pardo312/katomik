import 'log_event.dart';

abstract class LogOutput {
  void output(LogEvent event);
  Future<void> dispose() async {}
}

class ConsoleLogOutput extends LogOutput {
  final bool useColors;
  final bool includeTimestamp;

  ConsoleLogOutput({
    this.useColors = true,
    this.includeTimestamp = true,
  });

  @override
  void output(LogEvent event) {
    final message = includeTimestamp 
        ? event.toFormattedString() 
        : '${event.level.prefix} [${event.logger}] ${event.message}';
    
    // ignore: avoid_print
    print(message);
  }
}

class MultiLogOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiLogOutput(this.outputs);

  @override
  void output(LogEvent event) {
    for (final output in outputs) {
      output.output(event);
    }
  }

  @override
  Future<void> dispose() async {
    for (final output in outputs) {
      await output.dispose();
    }
  }
}