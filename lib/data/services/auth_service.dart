import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'graphql_client.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // GraphQL Mutations
  static const String _loginMutation = r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        user {
          id
          email
          username
          displayName
          avatarUrl
          bio
          timezone
          isActive
          emailVerified
          googleId
          createdAt
          updatedAt
        }
        accessToken
        refreshToken
      }
    }
  ''';

  static const String _registerMutation = r'''
    mutation Register($input: RegisterInput!) {
      register(input: $input) {
        user {
          id
          email
          username
          displayName
          avatarUrl
          bio
          timezone
          isActive
          emailVerified
          googleId
          createdAt
          updatedAt
        }
        accessToken
        refreshToken
      }
    }
  ''';

  static const String _refreshTokenMutation = r'''
    mutation RefreshToken($refreshToken: String!) {
      refreshToken(refreshToken: $refreshToken) {
        user {
          id
          email
          username
          displayName
          avatarUrl
          bio
          timezone
          isActive
          emailVerified
          googleId
          createdAt
          updatedAt
        }
        accessToken
        refreshToken
      }
    }
  ''';

  static const String _meQuery = r'''
    query Me {
      me {
        id
        email
        username
        displayName
        avatarUrl
        bio
        timezone
        isActive
        emailVerified
        googleId
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _googleLoginMutation = r'''
    mutation GoogleLogin($input: GoogleLoginInput!) {
      googleLogin(input: $input) {
        user {
          id
          email
          username
          displayName
          avatarUrl
          bio
          timezone
          isActive
          emailVerified
          googleId
          createdAt
          updatedAt
        }
        accessToken
        refreshToken
      }
    }
  ''';

  // Login method
  Future<AuthResult> login(String emailOrUsername, String password) async {
    try {
      final client = GraphQLConfig.getUnauthenticatedClient();

      final result = await client.mutate(
        MutationOptions(
          document: gql(_loginMutation),
          variables: {
            'input': {'emailOrUsername': emailOrUsername, 'password': password},
          },
        ),
      );

      if (result.hasException) {
        throw _handleException(result.exception!);
      }

      final data = result.data?['login'];
      if (data == null) {
        throw Exception('Login failed: No data returned');
      }

      // Store tokens securely
      await _storeTokens(data['accessToken'], data['refreshToken']);

      return AuthResult(
        user: User.fromJson(data['user']),
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register method
  Future<AuthResult> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String? timezone,
  }) async {
    try {
      final client = GraphQLConfig.getUnauthenticatedClient();

      final result = await client.mutate(
        MutationOptions(
          document: gql(_registerMutation),
          variables: {
            'input': {
              'email': email,
              'username': username,
              'password': password,
              'displayName': displayName,
              if (timezone != null) 'timezone': timezone,
            },
          },
        ),
      );

      if (result.hasException) {
        throw _handleException(result.exception!);
      }

      final data = result.data?['register'];
      if (data == null) {
        throw Exception('Registration failed: No data returned');
      }

      // Store tokens securely
      await _storeTokens(data['accessToken'], data['refreshToken']);

      return AuthResult(
        user: User.fromJson(data['user']),
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Refresh token method
  Future<AuthResult> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final client = GraphQLConfig.getUnauthenticatedClient();

      final result = await client.mutate(
        MutationOptions(
          document: gql(_refreshTokenMutation),
          variables: {'refreshToken': refreshToken},
        ),
      );

      if (result.hasException) {
        throw _handleException(result.exception!);
      }

      final data = result.data?['refreshToken'];
      if (data == null) {
        throw Exception('Token refresh failed: No data returned');
      }

      // Store new tokens
      await _storeTokens(data['accessToken'], data['refreshToken']);

      return AuthResult(
        user: User.fromJson(data['user']),
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Get current user
  Future<User?> getCurrentUser({bool skipCache = false}) async {
    try {
      final client = await GraphQLConfig.getClient();

      final result = await client.query(
        QueryOptions(
          document: gql(_meQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleException(result.exception!);
      }

      final data = result.data?['me'];
      if (data == null) {
        return null;
      }

      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return false;

      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the ID token
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Send the ID token to our backend
      final client = GraphQLConfig.getUnauthenticatedClient();

      final result = await client.mutate(
        MutationOptions(
          document: gql(_googleLoginMutation),
          variables: {
            'input': {'idToken': idToken},
          },
        ),
      );

      if (result.hasException) {
        throw _handleException(result.exception!);
      }

      final data = result.data?['googleLogin'];
      if (data == null) {
        throw Exception('Google login failed: No data returned');
      }

      // Store tokens securely
      await _storeTokens(data['accessToken'], data['refreshToken']);

      return AuthResult(
        user: User.fromJson(data['user']),
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    await _googleSignIn.signOut();
  }

  // Helper method to store tokens
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  // Handle GraphQL exceptions
  String _handleException(OperationException exception) {
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      // Check if it's a validation error with details
      if (error.extensions != null &&
          error.extensions!['originalError'] != null) {
        final originalError = error.extensions!['originalError'];
        if (originalError['message'] is List) {
          return (originalError['message'] as List).join(', ');
        }
        return originalError['message'] ?? error.message;
      }
      return error.message;
    } else {
      return 'Network error: Please check your connection';
    }
  }
}

// Auth result model
class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}
