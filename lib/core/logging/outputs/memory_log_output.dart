import 'dart:collection';
import '../log_event.dart';
import '../log_output.dart';

class MemoryLogOutput extends LogOutput {
  final int maxEvents;
  final Queue<LogEvent> _events = Queue<LogEvent>();

  MemoryLogOutput({this.maxEvents = 1000});

  @override
  void output(LogEvent event) {
    _events.addLast(event);
    while (_events.length > maxEvents) {
      _events.removeFirst();
    }
  }

  List<LogEvent> get events => _events.toList();

  void clear() {
    _events.clear();
  }

  List<String> getFormattedLogs() {
    return _events.map((e) => e.toFormattedString()).toList();
  }

  String exportAsText() {
    return _events.map((e) => e.toFormattedString()).join('\n');
  }

  Map<String, dynamic> exportAsJson() {
    return {
      'logs': _events.map((e) => e.toJson()).toList(),
      'count': _events.length,
      'maxEvents': maxEvents,
    };
  }
}