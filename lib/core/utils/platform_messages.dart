import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../platform/platform_service.dart';

class PlatformMessages {
  static void showMessage(BuildContext context, String message, {bool isError = false}) {
    if (context.platform.isIOS) {
      // For iOS, show a CupertinoDialog or use a custom overlay
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).ok),
            ),
          ],
        ),
      );
    } else {
      // For Android, try to find ScaffoldMessenger in the widget tree
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : null,
          ),
        );
      } else {
        // Fallback: show a dialog if ScaffoldMessenger is not available
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).ok),
              ),
            ],
          ),
        );
      }
    }
  }

  static void showSuccess(BuildContext context, String message) {
    showMessage(context, message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    showMessage(context, message, isError: true);
  }
}