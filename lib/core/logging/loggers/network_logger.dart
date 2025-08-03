import 'dart:convert';
import '../logger.dart';
import '../log_level.dart';

class NetworkLogger {
  static final _logger = Logger.forModule('Network');

  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    String? operationType,
  }) {
    _logger.debug(
      'Request: $method $url',
      metadata: {
        'method': method,
        'url': url,
        'operationType': operationType,
        if (headers != null) 'headers': _sanitizeHeaders(headers),
        if (body != null) 'body': _truncateBody(body),
      },
    );
  }

  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    required Duration duration,
    String? operationType,
  }) {
    final level = statusCode >= 400 ? LogLevel.error : LogLevel.debug;
    
    _logger.log(
      level,
      'Response: $statusCode $method $url',
      metadata: {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        'duration_ms': duration.inMilliseconds,
        'operationType': operationType,
        if (headers != null) 'headers': _sanitizeHeaders(headers),
        if (body != null) 'body': _truncateBody(body),
      },
    );
  }

  static void logGraphQLOperation({
    required String operation,
    required String operationName,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? result,
    Object? error,
    Duration? duration,
  }) {
    if (error != null) {
      _logger.error(
        'GraphQL Error: $operationName',
        metadata: {
          'operation': operation,
          'operationName': operationName,
          'variables': _sanitizeVariables(variables),
          'error': error.toString(),
          if (duration != null) 'duration_ms': duration.inMilliseconds,
        },
        error: error,
      );
    } else {
      _logger.debug(
        'GraphQL Success: $operationName',
        metadata: {
          'operation': operation,
          'operationName': operationName,
          'variables': _sanitizeVariables(variables),
          if (result != null) 'hasData': result.containsKey('data'),
          if (duration != null) 'duration_ms': duration.inMilliseconds,
        },
      );
    }
  }

  static void logNetworkError({
    required String url,
    required Object error,
    StackTrace? stackTrace,
    String? operation,
  }) {
    _logger.error(
      'Network Error: $url',
      metadata: {
        'url': url,
        'operation': operation,
        'errorType': error.runtimeType.toString(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    final sensitiveHeaders = ['authorization', 'cookie', 'x-api-key'];
    
    for (final key in sensitiveHeaders) {
      if (sanitized.containsKey(key.toLowerCase())) {
        sanitized[key.toLowerCase()] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  static Map<String, dynamic>? _sanitizeVariables(Map<String, dynamic>? variables) {
    if (variables == null) return null;
    
    final sanitized = Map<String, dynamic>.from(variables);
    final sensitiveFields = ['password', 'token', 'secret', 'apiKey'];
    
    void sanitizeMap(Map<String, dynamic> map) {
      for (final entry in map.entries.toList()) {
        if (sensitiveFields.any((field) => 
            entry.key.toLowerCase().contains(field))) {
          map[entry.key] = '[REDACTED]';
        } else if (entry.value is Map<String, dynamic>) {
          sanitizeMap(entry.value);
        }
      }
    }
    
    sanitizeMap(sanitized);
    return sanitized;
  }

  static dynamic _truncateBody(dynamic body) {
    String bodyStr;
    
    if (body is String) {
      bodyStr = body;
    } else {
      try {
        bodyStr = jsonEncode(body);
      } catch (_) {
        bodyStr = body.toString();
      }
    }
    
    const maxLength = 1000;
    if (bodyStr.length > maxLength) {
      return '${bodyStr.substring(0, maxLength)}... [truncated]';
    }
    
    return body;
  }
}