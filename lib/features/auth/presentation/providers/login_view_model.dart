import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;

  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;
  bool get isAuthenticated => _authProvider.isAuthenticated;

  LoginViewModel(this._authProvider);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notifyListenersSafely() {
    if (!_disposed) notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    _notifyListenersSafely();
  }

  void clearError() {
    _error = null;
    _notifyListenersSafely();
  }

  Future<bool> login(
    String email,
    String password, {
    AppLocalizations? l10n,
  }) async {
    _isLoading = true;
    _error = null;
    _notifyListenersSafely();

    try {
      await _authProvider.login(email, password);
      return _authProvider.isAuthenticated;
    } catch (e) {
      _error = _parseError(e.toString(), l10n: l10n);
      return false;
    } finally {
      _isLoading = false;
      _notifyListenersSafely();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    _notifyListenersSafely();

    try {
      await _authProvider.signInWithGoogle();
      return _authProvider.isAuthenticated;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      _notifyListenersSafely();
    }
  }

  String _parseError(String message, {AppLocalizations? l10n}) {
    if (message.contains('Invalid credentials') ||
        message.contains('invalid credentials')) {
      return l10n?.invalidCredentials ?? '';
    } else if (message.contains('User not found')) {
      return l10n?.noAccountFound ?? '';
    } else if (message.contains('Network error')) {
      return l10n?.unableToConnect ?? '';
    } else if (message.contains('Bad Request Exception')) {
      return l10n?.checkLoginDetails ?? '';
    }
    return message;
  }
}
