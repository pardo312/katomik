import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraphQLConfig {
  static GraphQLClient? _client;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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
          print('GraphQL Client - Adding auth header');
          return 'Bearer $token';
        }
        print('GraphQL Client - No auth token available');
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
    _client = null;
  }
}