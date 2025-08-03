import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/logging/logging.dart';

class GraphQLConfig {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final _logger = Logger.forModule('GraphQLConfig');

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

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }

  static void clearClient() {
    // Client is no longer cached, so nothing to clear
  }
}