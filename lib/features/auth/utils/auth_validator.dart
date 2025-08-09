class AuthValidator {
  static const int minPasswordLength = 8;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }
  
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < minUsernameLength) {
      return 'Username must be at least $minUsernameLength characters';
    }
    if (value.length > maxUsernameLength) {
      return 'Username must be less than $maxUsernameLength characters';
    }
    if (!_usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
  
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
  
  static bool isValidUsername(String username) {
    return username.length >= minUsernameLength && 
           username.length <= maxUsernameLength && 
           _usernameRegex.hasMatch(username);
  }
}