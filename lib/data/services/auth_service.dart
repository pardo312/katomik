import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'graphql_client.dart';
import '../../shared/models/user.dart';
import '../../core/logging/logging.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  static final _logger = Logger.forModule('AuthService');

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
    AuthLogger.logLoginAttempt(
      method: 'email',
      email: emailOrUsername.contains('@') ? emailOrUsername : null,
    );

    try {
      final client = GraphQLConfig.getUnauthenticatedClient();

      final stopwatch = Stopwatch()..start();
      final result = await client.mutate(
        MutationOptions(
          document: gql(_loginMutation),
          variables: {
            'input': {'emailOrUsername': emailOrUsername, 'password': password},
          },
        ),
      );
      stopwatch.stop();

      NetworkLogger.logGraphQLOperation(
        operation: 'mutation',
        operationName: 'Login',
        variables: {'emailOrUsername': emailOrUsername},
        result: result.data,
        error: result.exception,
        duration: stopwatch.elapsed,
      );

      if (result.hasException) {
        final error = _handleException(result.exception!);
        AuthLogger.logLoginFailure(
          reason: error,
          method: 'email',
          email: emailOrUsername.contains('@') ? emailOrUsername : null,
          error: result.exception,
        );
        throw error;
      }

      final data = result.data?['login'];
      if (data == null) {
        const error = 'Login failed: No data returned';
        AuthLogger.logLoginFailure(
          reason: error,
          method: 'email',
          email: emailOrUsername.contains('@') ? emailOrUsername : null,
        );
        throw Exception(error);
      }

      // Store tokens securely
      await _storeTokens(data['accessToken'], data['refreshToken']);

      final user = User.fromJson(data['user']);
      AuthLogger.logLoginSuccess(
        userId: user.id,
        method: 'email',
        email: user.email,
      );

      return AuthResult(
        user: user,
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      _logger.error('Login failed', error: e);
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
    _logger.info('Registration attempt', metadata: {
      'username': username,
      'email': _obfuscateEmail(email),
    });

    try {
      final client = GraphQLConfig.getUnauthenticatedClient();

      final stopwatch = Stopwatch()..start();
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
      stopwatch.stop();

      NetworkLogger.logGraphQLOperation(
        operation: 'mutation',
        operationName: 'Register',
        variables: {'email': email, 'username': username},
        result: result.data,
        error: result.exception,
        duration: stopwatch.elapsed,
      );

      if (result.hasException) {
        final error = _handleException(result.exception!);
        AuthLogger.logRegistration(
          success: false,
          email: email,
          error: result.exception,
        );
        throw error;
      }

      final data = result.data?['register'];
      if (data == null) {
        const error = 'Registration failed: No data returned';
        AuthLogger.logRegistration(
          success: false,
          email: email,
          error: error,
        );
        throw Exception(error);
      }

      // Store tokens securely
      await _storeTokens(data['accessToken'], data['refreshToken']);

      final user = User.fromJson(data['user']);
      AuthLogger.logRegistration(
        success: true,
        email: email,
        userId: user.id,
      );

      return AuthResult(
        user: user,
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      _logger.error('Registration failed', error: e);
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Refresh token method
  Future<AuthResult> refreshToken() async {
    _logger.debug('Attempting token refresh');

    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        const error = 'No refresh token found';
        AuthLogger.logTokenRefresh(success: false, error: error);
        throw Exception(error);
      }

      final client = GraphQLConfig.getUnauthenticatedClient();

      final result = await _logger.timeAsync(
        'Token refresh',
        () => client.mutate(
          MutationOptions(
            document: gql(_refreshTokenMutation),
            variables: {'refreshToken': refreshToken},
          ),
        ),
      );

      if (result.hasException) {
        final error = _handleException(result.exception!);
        AuthLogger.logTokenRefresh(success: false, error: result.exception);
        throw error;
      }

      final data = result.data?['refreshToken'];
      if (data == null) {
        const error = 'Token refresh failed: No data returned';
        AuthLogger.logTokenRefresh(success: false, error: error);
        throw Exception(error);
      }

      // Store new tokens
      await _storeTokens(data['accessToken'], data['refreshToken']);

      final user = User.fromJson(data['user']);
      AuthLogger.logTokenRefresh(success: true, userId: user.id);

      return AuthResult(
        user: user,
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      _logger.error('Token refresh failed', error: e);
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
    AuthLogger.logLoginAttempt(method: 'google', provider: 'google');

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        const error = 'Google sign in was cancelled';
        AuthLogger.logLoginFailure(
          reason: error,
          method: 'google',
          error: error,
        );
        throw Exception(error);
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

      _logger.debug('Sending Google ID token to backend');
      final result = await _logger.timeAsync(
        'Google login backend call',
        () => client.mutate(
          MutationOptions(
            document: gql(_googleLoginMutation),
            variables: {
              'input': {'idToken': idToken},
            },
          ),
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

      final user = User.fromJson(data['user']);
      AuthLogger.logLoginSuccess(
        userId: user.id,
        method: 'google',
        email: user.email,
      );

      return AuthResult(
        user: user,
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    } catch (e) {
      _logger.error('Google sign in failed', error: e);
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    _logger.info('User logging out');
    await _secureStorage.deleteAll();
    await _googleSignIn.signOut();
    _logger.info('Logout completed');
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

  // Helper method to obfuscate email for logging
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
