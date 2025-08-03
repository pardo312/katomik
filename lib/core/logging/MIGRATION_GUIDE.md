# Logging System Migration Guide

## Overview
This guide helps you migrate from print/debugPrint statements to the new comprehensive logging system.

## 1. Initialize Logging System

Add to `main.dart`:
```dart
import 'core/logging/logging_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  LoggingInit.initialize(
    enableFileLogging: true,
    enableCrashReporting: true,
  );
  
  runApp(MyApp());
}
```

## 2. Basic Logger Usage

### Replace print statements:
```dart
// Before:
print('Loading habits...');

// After:
final _logger = Logger.forModule('HabitProvider');
_logger.info('Loading habits...');
```

### Replace debugPrint statements:
```dart
// Before:
debugPrint('Error: $error');

// After:
_logger.error('Operation failed', error: error, stackTrace: stack);
```

## 3. Migration Patterns

### Error Handling
```dart
// Before:
try {
  // operation
} catch (e) {
  print('Error: $e');
  throw Exception('Operation failed: ${e.toString()}');
}

// After:
try {
  // operation
} catch (e, stack) {
  _logger.error('Operation failed', error: e, stackTrace: stack);
  throw Exception('Operation failed: ${e.toString()}');
}
```

### Network Operations
```dart
// Before:
print('Calling API...');
final result = await apiCall();
print('API returned: $result');

// After:
NetworkLogger.logRequest(
  method: 'POST',
  url: apiUrl,
  body: requestBody,
);

final result = await apiCall();

NetworkLogger.logResponse(
  method: 'POST',
  url: apiUrl,
  statusCode: 200,
  body: result,
  duration: stopwatch.elapsed,
);
```

### Authentication
```dart
// Before:
print('User logged in: $userId');

// After:
AuthLogger.logLoginSuccess(
  userId: userId,
  method: 'email',
  email: userEmail,
);
```

### Performance Monitoring
```dart
// Before:
final start = DateTime.now();
await operation();
print('Operation took: ${DateTime.now().difference(start)}');

// After:
await _logger.timeAsync('Operation name', () => operation());
```

## 4. Module-Specific Loggers

### Available Specialized Loggers:
- `NetworkLogger` - HTTP/GraphQL operations
- `AuthLogger` - Authentication events
- `PerformanceLogger` - Performance metrics
- `AnalyticsLogger` - User behavior tracking
- `UILogger` - UI events and errors

## 5. Log Levels

Use appropriate log levels:
- `verbose()` - Detailed debugging info
- `debug()` - Debug information
- `info()` - General information
- `warning()` - Warning conditions
- `error()` - Error conditions
- `fatal()` - Fatal errors (triggers crash reporting)

## 6. Structured Logging

Add metadata to logs:
```dart
_logger.info('User action', metadata: {
  'action': 'create_habit',
  'habitName': habitName,
  'timestamp': DateTime.now().toIso8601String(),
});
```

## 7. Crash Reporting

Report critical errors:
```dart
CrashReporter.reportError(
  error: exception,
  stackTrace: stack,
  metadata: {'context': 'habit_creation'},
  fatal: true,
);
```

## 8. Migration Checklist

- [ ] Initialize logging in main.dart
- [ ] Replace all print() statements
- [ ] Replace all debugPrint() statements
- [ ] Add error logging to all try-catch blocks
- [ ] Add network logging to API calls
- [ ] Add auth logging to auth flows
- [ ] Add performance logging to critical operations
- [ ] Add UI logging for user interactions
- [ ] Test logging output in debug mode
- [ ] Verify log filtering in release mode

## 9. Best Practices

1. **Use module-specific loggers**: Create one logger per class/module
2. **Include context**: Always add relevant metadata
3. **Log at appropriate levels**: Don't use error() for warnings
4. **Avoid sensitive data**: Never log passwords, tokens, or PII
5. **Performance conscious**: Use verbose() for high-frequency logs
6. **Structured data**: Use metadata instead of string concatenation
7. **Error context**: Always include stack traces for errors

## 10. Common Patterns

### Service Layer
```dart
class MyService {
  static final _logger = Logger.forModule('MyService');
  
  Future<void> operation() async {
    return _logger.timeAsync('operation_name', () async {
      // implementation
    });
  }
}
```

### Provider Layer
```dart
class MyProvider extends ChangeNotifier {
  final _logger = Logger.forModule('MyProvider');
  
  void updateState() {
    _logger.debug('State update', metadata: {'oldValue': _value});
    _value = newValue;
    notifyListeners();
  }
}
```

### UI Layer
```dart
onTap: () {
  UILogger.logGesture(
    gesture: 'tap',
    widget: 'MyButton',
    action: 'perform_action',
  );
  // handle tap
}
```