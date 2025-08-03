import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/profile_service.dart';
import '../../../core/utils/platform_messages.dart';

mixin AvatarUploadMixin<T extends StatefulWidget> on State<T> {
  final ProfileService _profileService = ProfileService();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> handleAvatarUpload(ImageSource source) async {
    try {
      setState(() => _isUploading = true);
      
      final imageFile = await _profileService.pickImage(source: source);
      if (imageFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      final updatedUser = await _profileService.uploadAvatar(imageFile);
      
      if (mounted) {
        context.read<AuthProvider>().updateUser(updatedUser);
        setState(() => _isUploading = false);
        
        PlatformMessages.showSuccess(context, 'Profile picture updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        PlatformMessages.showError(context, 'Failed to upload avatar: ${e.toString()}');
      }
    }
  }

  Future<void> handleSyncGoogleAvatar() async {
    try {
      setState(() => _isUploading = true);
      
      final updatedUser = await _profileService.syncGoogleAvatar();
      
      if (mounted) {
        context.read<AuthProvider>().updateUser(updatedUser);
        setState(() => _isUploading = false);
        
        PlatformMessages.showSuccess(context, 'Google profile picture synced successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        PlatformMessages.showError(context, 'Failed to sync Google avatar: ${e.toString()}');
      }
    }
  }
}