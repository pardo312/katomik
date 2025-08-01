import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraphQLConfig {
  // TODO: Update this URL with your actual backend URL
  // For local development: 'http://localhost:3000/graphql'
  // For Android emulator: 'http://10.0.2.2:3000/graphql'
  // For iOS simulator: 'http://localhost:3000/graphql'
  // For production: 'https://your-domain.com/graphql'
  static const String baseUrl = 'http://localhost:3000/graphql';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  static Future<GraphQLClient> getClient() async {
    final token = await getAccessToken();
    
    final HttpLink httpLink = HttpLink(baseUrl);
    
    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }

  static GraphQLClient getUnauthenticatedClient() {
    final HttpLink httpLink = HttpLink(baseUrl);

    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: httpLink,
    );
  }
}