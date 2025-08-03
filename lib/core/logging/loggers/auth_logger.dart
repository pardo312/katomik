import '../logger.dart';
import '../log_level.dart';

class AuthLogger {
  static final _logger = Logger.forModule('Auth');

  static void logLoginAttempt({
    required String method,
    String? email,
    String? provider,
  }) {
    _logger.info(
      'Login attempt',
      metadata: {
        'method': method,
        if (email != null) 'email': _obfuscateEmail(email),
        if (provider != null) 'provider': provider,
      },
    );
  }

  static void logLoginSuccess({
    required String userId,
    required String method,
    String? email,
  }) {
    _logger.info(
      'Login successful',
      metadata: {
        'userId': userId,
        'method': method,
        if (email != null) 'email': _obfuscateEmail(email),
      },
    );
  }

  static void logLoginFailure({
    required String reason,
    required String method,
    String? email,
    Object? error,
  }) {
    _logger.warning(
      'Login failed',
      metadata: {
        'reason': reason,
        'method': method,
        if (email != null) 'email': _obfuscateEmail(email),
      },
      error: error,
    );
  }

  static void logLogout({
    required String userId,
    String? reason,
  }) {
    _logger.info(
      'User logged out',
      metadata: {
        'userId': userId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  static void logTokenRefresh({
    required bool success,
    String? userId,
    Object? error,
  }) {
    if (success) {
      _logger.debug(
        'Token refreshed successfully',
        metadata: {
          if (userId != null) 'userId': userId,
        },
      );
    } else {
      _logger.warning(
        'Token refresh failed',
        metadata: {
          if (userId != null) 'userId': userId,
        },
        error: error,
      );
    }
  }

  static void logRegistration({
    required bool success,
    String? email,
    String? userId,
    Object? error,
  }) {
    if (success) {
      _logger.info(
        'User registration successful',
        metadata: {
          if (email != null) 'email': _obfuscateEmail(email),
          if (userId != null) 'userId': userId,
        },
      );
    } else {
      _logger.warning(
        'User registration failed',
        metadata: {
          if (email != null) 'email': _obfuscateEmail(email),
        },
        error: error,
      );
    }
  }

  static void logPermissionCheck({
    required String permission,
    required bool granted,
    String? userId,
    String? resource,
  }) {
    _logger.debug(
      'Permission check: $permission',
      metadata: {
        'permission': permission,
        'granted': granted,
        if (userId != null) 'userId': userId,
        if (resource != null) 'resource': resource,
      },
    );
  }

  static void logSessionExpired({
    required String userId,
    String? lastActivity,
  }) {
    _logger.info(
      'Session expired',
      metadata: {
        'userId': userId,
        if (lastActivity != null) 'lastActivity': lastActivity,
      },
    );
  }

  static void logSecurityEvent({
    required String event,
    required String severity,
    String? userId,
    Map<String, dynamic>? details,
  }) {
    final level = severity == 'high' ? LogLevel.warning : LogLevel.info;
    
    _logger.log(
      level,
      'Security event: $event',
      metadata: {
        'event': event,
        'severity': severity,
        if (userId != null) 'userId': userId,
        if (details != null) ...details,
      },
    );
  }

  static String _obfuscateEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    
    final local = parts[0];
    final domain = parts[1];
    
    if (local.length <= 3) {
      return '***@$domain';
    }
    
    return '${local.substring(0, 2)}***@$domain';
  }
}