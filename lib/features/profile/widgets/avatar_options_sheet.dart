import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/platform/platform_service.dart';
import '../../../providers/auth_provider.dart';

class AvatarOptionsSheet {
  static void show({
    required BuildContext context,
    required Function(ImageSource) onImageSourceSelected,
    required VoidCallback onGoogleSync,
  }) {
    final hasGoogleAccount = context.read<AuthProvider>().user?.googleId != null;
    
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
        title: const Text('Change Profile Picture'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.camera);
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.gallery);
            },
            child: const Text('Choose from Gallery'),
          ),
          if (hasGoogleAccount)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onGoogleSync();
              },
              child: const Text('Use Google Profile Picture'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.gallery);
              },
            ),
            if (hasGoogleAccount)
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Use Google Profile Picture'),
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