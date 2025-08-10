import 'package:flutter/foundation.dart';
import '../../../../shared/providers/auth_provider.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  
  LoginViewModel(this._authProvider);
  
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authProvider.login(email, password);
      return _authProvider.isAuthenticated;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authProvider.signInWithGoogle();
      return _authProvider.isAuthenticated;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  String _parseError(String message) {
    if (message.contains('Invalid credentials') || message.contains('invalid credentials')) {
      return 'Invalid email/username or password. Please try again.';
    } else if (message.contains('User not found')) {
      return 'No account found with this email/username. Please register first.';
    } else if (message.contains('Network error')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (message.contains('Bad Request Exception')) {
      return 'Please check your login details and try again.';
    }
    return message;
  }
  
}