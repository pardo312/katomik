import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/platform_provider.dart';
import '../screens/login_screen.dart';
import '../../../../main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final platformProvider = context.watch<PlatformProvider>();

    // Show loading indicator while checking auth status
    if (authProvider.status == AuthStatus.loading ||
        authProvider.status == AuthStatus.uninitialized) {
      if (platformProvider.isIOS) {
        return const CupertinoPageScaffold(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      } else {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }

    // Show login screen if not authenticated
    if (authProvider.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    }

    // Show main screen if authenticated
    return const MainScreen();
  }
}