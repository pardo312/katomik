import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../log_event.dart';
import '../log_output.dart';

class FileLogOutput extends LogOutput {
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxFiles = 5;
  
  File? _currentFile;
  IOSink? _sink;
  final String filePrefix;
  final String fileExtension;
  Directory? _logDirectory;
  
  FileLogOutput({
    this.filePrefix = 'katomik',
    this.fileExtension = 'log',
  });

  Future<Directory> _getLogDirectory() async {
    if (_logDirectory != null) return _logDirectory!;
    
    final appDir = await getApplicationDocumentsDirectory();
    _logDirectory = Directory(path.join(appDir.path, 'logs'));
    
    if (!await _logDirectory!.exists()) {
      await _logDirectory!.create(recursive: true);
    }
    
    return _logDirectory!;
  }

  Future<File> _getCurrentLogFile() async {
    if (_currentFile != null) {
      final size = await _currentFile!.length();
      if (size < _maxFileSize) {
        return _currentFile!;
      }
      await _rotateLogFile();
    }
    
    final dir = await _getLogDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = '${filePrefix}_$timestamp.$fileExtension';
    _currentFile = File(path.join(dir.path, fileName));
    
    return _currentFile!;
  }

  Future<void> _rotateLogFile() async {
    await _closeSink();
    await _cleanupOldFiles();
  }

  Future<void> _cleanupOldFiles() async {
    final dir = await _getLogDirectory();
    final files = await dir
        .list()
        .where((entity) => 
            entity is File && 
            path.basename(entity.path).startsWith(filePrefix))
        .cast<File>()
        .toList();
    
    if (files.length <= _maxFiles) return;
    
    files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    
    for (var i = 0; i < files.length - _maxFiles; i++) {
      await files[i].delete();
    }
  }

  Future<void> _closeSink() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }

  @override
  void output(LogEvent event) {
    _writeToFile(event);
  }

  Future<void> _writeToFile(LogEvent event) async {
    try {
      final file = await _getCurrentLogFile();
      _sink ??= file.openWrite(mode: FileMode.append);
      _sink!.writeln(event.toFormattedString());
    } catch (e) {
      // Silently fail - we can't log errors in the logging system itself
      // ignore: avoid_print
      print('Failed to write log to file: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _closeSink();
  }

  Future<List<File>> getLogFiles() async {
    final dir = await _getLogDirectory();
    final files = await dir
        .list()
        .where((entity) => 
            entity is File && 
            path.basename(entity.path).startsWith(filePrefix))
        .cast<File>()
        .toList();
    
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  Future<String> exportLogs() async {
    final files = await getLogFiles();
    final buffer = StringBuffer();
    
    for (final file in files) {
      buffer.writeln('=== ${path.basename(file.path)} ===');
      buffer.writeln(await file.readAsString());
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}