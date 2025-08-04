import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:katomik/core/logging/logger_service.dart';

typedef RetryableOperation<T> = Future<T> Function();

class RetryOptions {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffFactor;
  final bool exponentialBackoff;
  final List<Type> retryableExceptions;
  final bool Function(dynamic error)? shouldRetry;

  const RetryOptions({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffFactor = 2.0,
    this.exponentialBackoff = true,
    this.retryableExceptions = const [],
    this.shouldRetry,
  });

  static const RetryOptions standard = RetryOptions();
  
  static const RetryOptions aggressive = RetryOptions(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 60),
    backoffFactor: 1.5,
  );
  
  static const RetryOptions conservative = RetryOptions(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 10),
    backoffFactor: 2.0,
  );
}

class RetryService {
  static final RetryService _instance = RetryService._internal();
  factory RetryService() => _instance;
  
  final _logger = LoggerService();
  final _connectivity = Connectivity();
  
  RetryService._internal() {
    _logger.setContext('RetryService');
  }

  /// Execute an operation with retry logic
  Future<T> execute<T>(
    RetryableOperation<T> operation, {
    required String operationName,
    RetryOptions options = RetryOptions.standard,
  }) async {
    _logger.debug('Starting retryable operation', data: {
      'operation': operationName,
      'maxAttempts': options.maxAttempts,
    });

    int attempt = 0;
    Duration delay = options.initialDelay;
    dynamic lastError;

    while (attempt < options.maxAttempts) {
      attempt++;
      
      try {
        _logger.debug('Attempting operation', data: {
          'operation': operationName,
          'attempt': attempt,
          'maxAttempts': options.maxAttempts,
        });

        final result = await operation();
        
        if (attempt > 1) {
          _logger.info('Operation succeeded after retry', data: {
            'operation': operationName,
            'attempt': attempt,
          });
        }
        
        return result;
      } catch (error, stackTrace) {
        lastError = error;
        
        _logger.warning('Operation failed', data: {
          'operation': operationName,
          'attempt': attempt,
          'error': error.toString(),
        });

        // Check if we should retry
        if (!_shouldRetry(error, attempt, options)) {
          _logger.error(
            'Operation failed - not retrying',
            error: error,
            stackTrace: stackTrace,
            data: {
              'operation': operationName,
              'attempt': attempt,
              'reason': 'Non-retryable error or max attempts reached',
            },
          );
          rethrow;
        }

        // Check network connectivity before retrying
        if (_isNetworkError(error)) {
          await _waitForConnectivity();
        }

        // Wait before retrying
        if (attempt < options.maxAttempts) {
          _logger.debug('Waiting before retry', data: {
            'operation': operationName,
            'delay': delay.inMilliseconds,
          });
          
          await Future.delayed(delay);
          
          // Calculate next delay
          if (options.exponentialBackoff) {
            delay = _calculateExponentialBackoff(
              delay,
              options.backoffFactor,
              options.maxDelay,
            );
          }
        }
      }
    }

    _logger.error(
      'Operation failed after all retries',
      error: lastError,
      data: {
        'operation': operationName,
        'attempts': attempt,
      },
    );

    throw RetryException(
      'Operation failed after $attempt attempts',
      lastError: lastError,
      attempts: attempt,
    );
  }

  /// Execute an operation with timeout and retry
  Future<T> executeWithTimeout<T>(
    RetryableOperation<T> operation, {
    required String operationName,
    required Duration timeout,
    RetryOptions options = RetryOptions.standard,
  }) async {
    return execute(
      () => operation().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'Operation timed out after ${timeout.inSeconds} seconds',
            timeout,
          );
        },
      ),
      operationName: operationName,
      options: options,
    );
  }

  bool _shouldRetry(dynamic error, int attempt, RetryOptions options) {
    if (attempt >= options.maxAttempts) {
      return false;
    }

    // Check custom retry condition
    if (options.shouldRetry != null) {
      return options.shouldRetry!(error);
    }

    // Check retryable exception types
    if (options.retryableExceptions.isNotEmpty) {
      return options.retryableExceptions.any((type) => error.runtimeType == type);
    }

    // Default retryable errors
    if (error is TimeoutException) return true;
    if (error is RetryableException) return true;
    if (_isNetworkError(error)) return true;
    
    // Don't retry on programming errors
    if (error is ArgumentError) return false;
    if (error is StateError) return false;
    if (error is UnsupportedError) return false;
    
    return false;
  }

  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket') ||
           errorString.contains('host');
  }

  Duration _calculateExponentialBackoff(
    Duration currentDelay,
    double factor,
    Duration maxDelay,
  ) {
    final nextDelay = Duration(
      milliseconds: (currentDelay.inMilliseconds * factor).round(),
    );
    
    // Add jitter to prevent thundering herd
    final jitter = Random().nextInt(1000);
    final delayWithJitter = Duration(
      milliseconds: nextDelay.inMilliseconds + jitter,
    );
    
    return delayWithJitter > maxDelay ? maxDelay : delayWithJitter;
  }

  Future<void> _waitForConnectivity() async {
    _logger.info('Waiting for network connectivity');
    
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _logger.info('No network connection, waiting for connectivity');
      
      // Wait for connectivity with timeout
      await _connectivity.onConnectivityChanged
          .firstWhere((results) => !results.contains(ConnectivityResult.none))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              _logger.warning('Timeout waiting for connectivity');
              return [ConnectivityResult.none];
            },
          );
    }
  }
}

class RetryException implements Exception {
  final String message;
  final dynamic lastError;
  final int attempts;

  RetryException(
    this.message, {
    this.lastError,
    required this.attempts,
  });

  @override
  String toString() => 'RetryException: $message (attempts: $attempts)';
}

class RetryableException implements Exception {
  final String message;

  RetryableException(this.message);

  @override
  String toString() => 'RetryableException: $message';
}