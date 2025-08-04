import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/logging/logging.dart';
import '../data/services/auth_service.dart';

class GraphQLConfig {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final _logger = Logger.forModule('GraphQLConfig');
  static AuthService? _authService;
  static bool _isRefreshing = false;

  static Future<GraphQLClient> getClient() async {
    // Don't cache the client to ensure fresh tokens
    final HttpLink httpLink = HttpLink(
      'http://localhost:3000/graphql', // Update with your backend URL
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        // Fetch token dynamically on each request
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null) {
          _logger.debug('Adding auth header to GraphQL request');
          return 'Bearer $token';
        }
        _logger.debug('No auth token available for GraphQL request');
        return null;
      },
    );

    // Add error link to handle 401 errors
    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) {
        // Check if we have GraphQL errors
        if (response.errors != null) {
          for (final error in response.errors!) {
            // Check for unauthorized error
            if (error.message.toLowerCase().contains('unauthorized') ||
                error.extensions?['code'] == 'UNAUTHENTICATED' ||
                error.extensions?['code'] == 'UnauthorizedException') {
              _logger.debug('Received unauthorized error, attempting token refresh');
              
              // Handle token refresh inline
              return Stream.fromFuture(() async {
                // Prevent multiple simultaneous refresh attempts
                if (_isRefreshing) {
                  return false;
                }

                _isRefreshing = true;
                try {
                  // Get auth service instance
                  _authService ??= AuthService();
                  
                  // Try to refresh the token
                  await _authService!.refreshToken();
                  _logger.debug('Token refreshed successfully');
                  
                  return true; // Indicate that the request should be retried
                } catch (e) {
                  _logger.error('Token refresh failed', error: e);
                  return false; // Don't retry, let the error propagate
                } finally {
                  _isRefreshing = false;
                }
              }()).asyncExpand((shouldRetry) {
                if (shouldRetry) {
                  // Retry the request with the new token
                  return forward(request);
                } else {
                  // Return the original error response
                  return Stream.value(response);
                }
              });
            }
          }
        }
        // Return null to continue with the original response
        return null;
      },
    );

    final Link link = errorLink.concat(authLink).concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }

  static GraphQLClient getUnauthenticatedClient() {
    final HttpLink httpLink = HttpLink(
      'http://localhost:3000/graphql',
    );

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    );
  }

  static void clearClient() {
    // Client is no longer cached, so nothing to clear
    _authService = null;
  }
}