import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerHelper {
  static Future<void> showImagePicker({
    required BuildContext context,
    required Function(ImageSource) onSourceSelected,
  }) async {
    if (Platform.isIOS) {
      _showIOSPicker(context, onSourceSelected);
    } else {
      _showAndroidPicker(context, onSourceSelected);
    }
  }
  
  static void _showIOSPicker(BuildContext context, Function(ImageSource) onSourceSelected) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Photo Library'),
            onPressed: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.gallery);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  static void _showAndroidPicker(BuildContext context, Function(ImageSource) onSourceSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}