import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../../core/platform/platform_service.dart';

class LogoutConfirmationDialog {
  static Future<bool?> show(BuildContext context) {
    if (context.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context).logout),
          content: Text(AppLocalizations.of(context).areYouSureLogout),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              isDestructiveAction: true,
              child: Text(AppLocalizations.of(context).logout),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).logout),
          content: Text(AppLocalizations.of(context).areYouSureLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context).logout,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }
}