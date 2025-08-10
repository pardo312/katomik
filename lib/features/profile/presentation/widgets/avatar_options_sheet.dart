import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../../core/platform/platform_service.dart';
import '../../../../shared/providers/auth_provider.dart';

class AvatarOptionsSheet {
  static void show({
    required BuildContext context,
    required Function(ImageSource) onImageSourceSelected,
    required VoidCallback onGoogleSync,
  }) {
    final user = context.read<AuthProvider>().user;
    final hasGoogleAccount = user?.googleId != null;

    if (context.isIOS) {
      _showIOSOptions(
        context: context,
        onImageSourceSelected: onImageSourceSelected,
        onGoogleSync: onGoogleSync,
        hasGoogleAccount: hasGoogleAccount,
      );
    } else {
      _showAndroidOptions(
        context: context,
        onImageSourceSelected: onImageSourceSelected,
        onGoogleSync: onGoogleSync,
        hasGoogleAccount: hasGoogleAccount,
      );
    }
  }

  static void _showIOSOptions({
    required BuildContext context,
    required Function(ImageSource) onImageSourceSelected,
    required VoidCallback onGoogleSync,
    required bool hasGoogleAccount,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(AppLocalizations.of(context).changeProfilePicture),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.camera);
            },
            child: Text(AppLocalizations.of(context).takePhoto),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.gallery);
            },
            child: Text(AppLocalizations.of(context).chooseFromGallery),
          ),
          if (hasGoogleAccount)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onGoogleSync();
              },
              child: Text(AppLocalizations.of(context).useGoogleProfilePicture),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
      ),
    );
  }

  static void _showAndroidOptions({
    required BuildContext context,
    required Function(ImageSource) onImageSourceSelected,
    required VoidCallback onGoogleSync,
    required bool hasGoogleAccount,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context).takePhoto),
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(AppLocalizations.of(context).chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.gallery);
              },
            ),
            if (hasGoogleAccount)
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text(AppLocalizations.of(context).useGoogleProfilePicture),
                onTap: () {
                  Navigator.pop(context);
                  onGoogleSync();
                },
              ),
          ],
        ),
      ),
    );
  }
}
