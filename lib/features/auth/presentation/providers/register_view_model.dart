import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  
  String? get usernameError => _usernameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  
  RegisterViewModel(this._authProvider);
  
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearFieldErrors() {
    _usernameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    notifyListeners();
  }
  
  bool validateFields({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    AppLocalizations? l10n,
  }) {
    bool isValid = true;
    clearFieldErrors();
    
    if (username.isEmpty) {
      _usernameError = l10n?.pleaseEnterUsername ?? 'Please enter a username';
      isValid = false;
    } else if (username.length < 3) {
      _usernameError = l10n?.usernameMustBeAtLeastChars(3) ?? 'Username must be at least 3 characters';
      isValid = false;
    } else if (username.length > 50) {
      _usernameError = l10n?.usernameMustBeLessThanChars(50) ?? 'Username must be less than 50 characters';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      _usernameError = l10n?.usernameCanOnlyContain ?? 'Username can only contain letters, numbers, and underscores';
      isValid = false;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty) {
      _emailError = l10n?.pleaseEnterYourEmail ?? 'Please enter your email';
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = l10n?.pleaseEnterValidEmail ?? 'Please enter a valid email address';
      isValid = false;
    }
    
    if (password.isEmpty) {
      _passwordError = l10n?.pleaseEnterYourPassword ?? 'Please enter a password';
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = l10n?.passwordMustBeAtLeastChars(8) ?? 'Password must be at least 8 characters';
      isValid = false;
    }
    
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = l10n?.pleaseConfirmYourPassword ?? 'Please confirm your password';
      isValid = false;
    } else if (confirmPassword != password) {
      _confirmPasswordError = l10n?.passwordsDoNotMatch ?? 'Passwords do not match';
      isValid = false;
    }
    
    if (!isValid) {
      notifyListeners();
    }
    
    return isValid;
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    AppLocalizations? l10n,
  }) async {
    if (!validateFields(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      l10n: l10n,
    )) {
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authProvider.register(
        username: username,
        email: email,
        password: password,
        displayName: username,
      );
      return _authProvider.isAuthenticated;
    } catch (e) {
      _error = _parseError(e.toString(), l10n: l10n);
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
  
  String _parseError(String message, {AppLocalizations? l10n}) {
    if (message.contains('email already exists') || message.contains('Email already exists')) {
      return l10n?.emailAlreadyRegistered ?? 'This email is already registered. Please use a different email or login.';
    } else if (message.contains('username already exists') || message.contains('Username already exists')) {
      return l10n?.usernameAlreadyTaken ?? 'This username is already taken. Please choose a different username.';
    } else if (message.contains('password') && message.contains('short')) {
      return l10n?.passwordTooShort ?? 'Password must be at least 8 characters long.';
    } else if (message.contains('Bad Request Exception')) {
      return l10n?.checkLoginDetails ?? 'Please check your input and try again. Make sure your password is at least 8 characters.';
    }
    return message;
  }
}