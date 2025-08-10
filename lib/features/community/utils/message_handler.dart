import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class MessageHandler {
  static void showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isIOS = false,
  }) {
    if (isIOS) {
      _showIOSMessage(context, message);
    } else {
      _showAndroidMessage(context, message, isError);
    }
  }

  static void _showIOSMessage(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context).ok),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  static void _showAndroidMessage(
    BuildContext context,
    String message,
    bool isError,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelText ?? AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmText ?? AppLocalizations.of(context).confirm,
              style: TextStyle(
                color: isDestructive ? AppColors.error : null,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}