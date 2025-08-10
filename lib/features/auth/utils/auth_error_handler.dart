import 'package:flutter/widgets.dart';
import 'package:katomik/l10n/app_localizations.dart';

class AuthErrorHandler {
  static String parseLoginError(String message, BuildContext? context) {
    if (message.contains('Invalid credentials') || message.contains('invalid credentials')) {
      return context != null 
          ? AppLocalizations.of(context).invalidCredentials
          : 'Invalid email/username or password. Please try again.';
    } else if (message.contains('User not found')) {
      return context != null 
          ? AppLocalizations.of(context).noAccountFound
          : 'No account found with this email/username. Please register first.';
    } else if (message.contains('Network error')) {
      return context != null 
          ? AppLocalizations.of(context).unableToConnect
          : 'Unable to connect to server. Please check your internet connection.';
    } else if (message.contains('Bad Request Exception')) {
      return context != null 
          ? AppLocalizations.of(context).checkLoginDetails
          : 'Please check your login details and try again.';
    }
    return message;
  }
  
  static String parseRegisterError(String message, BuildContext? context) {
    if (message.contains('email already exists') || message.contains('Email already exists')) {
      return context != null 
          ? AppLocalizations.of(context).emailAlreadyRegistered
          : 'This email is already registered. Please use a different email or login.';
    } else if (message.contains('username already exists') || message.contains('Username already exists')) {
      return context != null 
          ? AppLocalizations.of(context).usernameAlreadyTaken
          : 'This username is already taken. Please choose a different username.';
    } else if (message.contains('password') && message.contains('short')) {
      return context != null 
          ? AppLocalizations.of(context).passwordTooShort
          : 'Password must be at least 8 characters long.';
    } else if (message.contains('Bad Request Exception')) {
      return context != null 
          ? AppLocalizations.of(context).pleaseCheckYourInput
          : 'Please check your input and try again. Make sure your password is at least 8 characters.';
    }
    return message;
  }
  
  static String parseGeneralError(String message, BuildContext? context) {
    if (message.contains('Network error') || message.contains('connection')) {
      return context != null 
          ? AppLocalizations.of(context).connectionError
          : 'Connection error. Please check your internet connection.';
    } else if (message.contains('timeout')) {
      return context != null 
          ? AppLocalizations.of(context).requestTimeout
          : 'Request timed out. Please try again.';
    } else if (message.contains('server')) {
      return context != null 
          ? AppLocalizations.of(context).serverError
          : 'Server error. Please try again later.';
    }
    return message;
  }
}