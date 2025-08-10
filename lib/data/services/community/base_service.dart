import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../services/graphql_client.dart';
import '../../../core/logging/logger_service.dart';
import '../../../core/network/retry_service.dart';
import 'error_handler.dart';

abstract class BaseCommunityService {
  final _logger = LoggerService();
  final _retryService = RetryService();
  final _errorHandler = CommunityErrorHandler();

  Future<T> executeQuery<T>({
    required String queryDocument,
    required Map<String, dynamic> variables,
    required T Function(Map<String, dynamic>) dataExtractor,
    required String operationName,
    bool useCache = true,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final startTime = DateTime.now();
    _logger.info('Executing $operationName', data: variables);

    try {
      final client = await GraphQLConfig.getClient();
      
      final result = await _executeWithRetry(
        () => client.query(
          QueryOptions(
            document: gql(queryDocument),
            variables: variables,
            fetchPolicy: useCache ? FetchPolicy.cacheFirst : FetchPolicy.networkOnly,
          ),
        ),
        operationName: operationName,
        timeout: timeout,
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in $operationName',
          error: result.exception,
          data: {'query': operationName},
        );
        _errorHandler.handleGraphQLException(result.exception!, null);
      }

      final data = result.data;
      if (data == null) {
        throw CommunityServiceException(
          'No data returned from $operationName',
          type: CommunityErrorType.unknown,
        );
      }

      final extractedData = dataExtractor(data);
      
      _logPerformance(operationName, startTime, extractedData);
      
      return extractedData;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to execute $operationName',
        error: e,
        stackTrace: stackTrace,
      );
      throw _errorHandler.mapException(e, null);
    }
  }

  Future<T> executeMutation<T>({
    required String mutationDocument,
    required Map<String, dynamic> variables,
    required T Function(Map<String, dynamic>) dataExtractor,
    required String operationName,
  }) async {
    final startTime = DateTime.now();
    _logger.info('Executing mutation $operationName', data: variables);

    try {
      final client = await GraphQLConfig.getClient();
      
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutationDocument),
          variables: variables,
        ),
      );

      if (result.hasException) {
        _logger.error(
          'GraphQL error in $operationName',
          error: result.exception,
          data: variables,
        );
        _errorHandler.handleGraphQLException(result.exception!, null);
      }

      final data = result.data;
      if (data == null) {
        throw CommunityServiceException(
          'No data returned from $operationName',
          type: CommunityErrorType.unknown,
        );
      }

      final extractedData = dataExtractor(data);
      
      _logPerformance(operationName, startTime, extractedData);
      
      return extractedData;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to execute mutation $operationName',
        error: e,
        stackTrace: stackTrace,
      );
      throw _errorHandler.mapException(e, null);
    }
  }

  Future<QueryResult> _executeWithRetry(
    Future<QueryResult> Function() operation, {
    required String operationName,
    required Duration timeout,
  }) async {
    return _retryService.executeWithTimeout(
      operation,
      operationName: operationName,
      timeout: timeout,
      options: RetryOptions(
        maxAttempts: 3,
        shouldRetry: (error) => _errorHandler.isRetryableError(error),
      ),
    );
  }

  void _logPerformance(String operation, DateTime startTime, dynamic result) {
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    
    Map<String, dynamic> performanceData = {
      'duration_ms': duration,
    };
    
    if (result is List) {
      performanceData['result_count'] = result.length;
    }
    
    _logger.logPerformance(operation, duration, data: performanceData);
  }
}