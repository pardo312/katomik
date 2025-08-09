import 'package:flutter/foundation.dart';
import '../data/services/auth_service.dart';
import '../data/models/user.dart';
import 'habit_provider.dart';
import 'community_provider.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  HabitProvider? _habitProvider;
  CommunityProvider? _communityProvider;
  
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initializeAuth();
  }

  // Set providers that need to be cleared on logout
  void setProviders(HabitProvider habitProvider, CommunityProvider communityProvider) {
    _habitProvider = habitProvider;
    _communityProvider = communityProvider;
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // Check if we have a valid token
      final isValid = await _authService.isTokenValid();
      
      if (isValid) {
        // Try to get current user
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
          _status = AuthStatus.authenticated;
          
          // Initialize habits for the authenticated user
          if (_habitProvider != null) {
            await _habitProvider!.initializeForUser(user.id);
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        // Try to refresh token
        try {
          final result = await _authService.refreshToken();
          _user = result.user;
          _status = AuthStatus.authenticated;
          
          // Initialize habits for the authenticated user
          if (_habitProvider != null && _user != null) {
            await _habitProvider!.initializeForUser(_user!.id);
          }
        } catch (e) {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }
    notifyListeners();
  }

  // Login method
  Future<void> login(String emailOrUsername, String password) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final result = await _authService.login(emailOrUsername, password);
      _user = result.user;
      _status = AuthStatus.authenticated;
      
      // Initialize habits for the logged-in user
      if (_habitProvider != null && _user != null) {
        await _habitProvider!.initializeForUser(_user!.id);
      }
      
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Register method
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String? timezone,
  }) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final result = await _authService.register(
        email: email,
        username: username,
        password: password,
        displayName: displayName,
        timezone: timezone,
      );
      
      _user = result.user;
      _status = AuthStatus.authenticated;
      
      // Initialize habits for the newly registered user
      if (_habitProvider != null && _user != null) {
        await _habitProvider!.initializeForUser(_user!.id);
      }
      
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Google Sign In method
  Future<void> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      _user = result.user;
      _status = AuthStatus.authenticated;
      
      // Initialize habits for the Google sign-in user
      if (_habitProvider != null && _user != null) {
        await _habitProvider!.initializeForUser(_user!.id);
      }
      
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authService.logout();
      
      // Clear data from other providers
      _habitProvider?.clearData();
      _communityProvider?.clearData();
      
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      if (_status != AuthStatus.authenticated) return;
      
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user data
  void updateUser(User user) {
    if (_status == AuthStatus.authenticated) {
      _user = user;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}