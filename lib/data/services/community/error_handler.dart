import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';

enum CommunityErrorType {
  network,
  server,
  notFound,
  unauthorized,
  duplicate,
  validation,
  unknown,
}

class CommunityServiceException implements Exception {
  final String message;
  final CommunityErrorType type;
  final dynamic originalError;

  CommunityServiceException(
    this.message, {
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'CommunityServiceException: $message (type: ${type.name})';
}

class CommunityErrorHandler {
  bool isRetryableError(dynamic error) {
    if (error is OperationException) {
      if (error.linkException != null) {
        final linkException = error.linkException!;
        if (linkException is NetworkException || linkException is ServerException) {
          return true;
        }
      }
      
      if (error.graphqlErrors.isNotEmpty) {
        final firstError = error.graphqlErrors.first;
        final message = firstError.message.toLowerCase();
        
        if (message.contains('unauthorized') || 
            message.contains('forbidden') ||
            message.contains('not found') ||
            message.contains('already exists') ||
            message.contains('invalid')) {
          return false;
        }
      }
      
      return true;
    }
    
    if (error is TimeoutException) return true;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket');
  }
  
  void handleGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      final linkException = exception.linkException!;
      if (linkException is NetworkException) {
        throw CommunityServiceException(
          'Network error. Please check your connection.',
          type: CommunityErrorType.network,
        );
      } else if (linkException is ServerException) {
        throw CommunityServiceException(
          'Server error. Please try again later.',
          type: CommunityErrorType.server,
        );
      }
    }

    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final message = error.message;
      
      if (message.contains('not found')) {
        throw CommunityServiceException(
          message,
          type: CommunityErrorType.notFound,
        );
      } else if (message.contains('unauthorized') || message.contains('forbidden')) {
        throw CommunityServiceException(
          message,
          type: CommunityErrorType.unauthorized,
        );
      } else if (message.contains('already')) {
        throw CommunityServiceException(
          message,
          type: CommunityErrorType.duplicate,
        );
      }
    }

    throw CommunityServiceException(
      'An unexpected error occurred',
      type: CommunityErrorType.unknown,
    );
  }

  Exception mapException(dynamic error) {
    if (error is CommunityServiceException) {
      return error;
    } else if (error is ArgumentError) {
      return CommunityServiceException(
        error.message?.toString() ?? 'Invalid argument',
        type: CommunityErrorType.validation,
      );
    } else if (error is Exception) {
      return CommunityServiceException(
        error.toString(),
        type: CommunityErrorType.unknown,
      );
    } else {
      return CommunityServiceException(
        'An unexpected error occurred',
        type: CommunityErrorType.unknown,
      );
    }
  }
}