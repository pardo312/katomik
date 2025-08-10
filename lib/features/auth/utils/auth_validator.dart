import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class AuthValidator {
  static const int minPasswordLength = 8;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  
  static String? Function(String?) getEmailValidator(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return (String? value) {
      if (value == null || value.isEmpty) {
        return l10n.pleaseEnterYourEmail;
      }
      if (!_emailRegex.hasMatch(value)) {
        return l10n.pleaseEnterValidEmail;
      }
      return null;
    };
  }
  
  static String? Function(String?) getPasswordValidator(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return (String? value) {
      if (value == null || value.isEmpty) {
        return l10n.pleaseEnterYourPassword;
      }
      if (value.length < minPasswordLength) {
        return l10n.passwordMustBeAtLeastChars(minPasswordLength);
      }
      return null;
    };
  }
  
  static String? Function(String?, String) getConfirmPasswordValidator(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return (String? value, String password) {
      if (value == null || value.isEmpty) {
        return l10n.pleaseConfirmYourPassword;
      }
      if (value != password) {
        return l10n.passwordsDoNotMatch;
      }
      return null;
    };
  }
  
  static String? Function(String?) getUsernameValidator(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return (String? value) {
      if (value == null || value.isEmpty) {
        return l10n.pleaseEnterUsername;
      }
      if (value.length < minUsernameLength) {
        return l10n.usernameMustBeAtLeastChars(minUsernameLength);
      }
      if (value.length > maxUsernameLength) {
        return l10n.usernameMustBeLessThanChars(maxUsernameLength);
      }
      if (!_usernameRegex.hasMatch(value)) {
        return l10n.usernameCanOnlyContain;
      }
      return null;
    };
  }
  
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