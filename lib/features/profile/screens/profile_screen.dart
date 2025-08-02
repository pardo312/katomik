import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/adaptive_widgets.dart';
import '../../../core/platform/platform_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/platform/platform_icons.dart';
import '../../../data/services/profile_service.dart';
import '../../../core/utils/platform_messages.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isUploading = false;

  Future<void> _handleAvatarUpload(ImageSource source) async {
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

  Future<void> _handleSyncGoogleAvatar() async {
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

  void _showAvatarOptions() {
    if (context.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Change Profile Picture'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _handleAvatarUpload(ImageSource.camera);
              },
              child: const Text('Take Photo'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _handleAvatarUpload(ImageSource.gallery);
              },
              child: const Text('Choose from Gallery'),
            ),
            if (context.read<AuthProvider>().user?.googleId != null)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _handleSyncGoogleAvatar();
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
    } else {
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
                  _handleAvatarUpload(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _handleAvatarUpload(ImageSource.gallery);
                },
              ),
              if (context.read<AuthProvider>().user?.googleId != null)
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Use Google Profile Picture'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleSyncGoogleAvatar();
                  },
                ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await _showLogoutConfirmation(context);
    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
    }
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    if (context.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              isDestructiveAction: true,
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return AdaptiveScaffold(
      title: const Text('Profile'),
      body: SafeArea(
        child: ListView(
          children: [
            // User info section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploading ? null : _showAvatarOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          ),
                          child: ClipOval(
                            child: user?.avatarUrl != null
                                ? Image.network(
                                    user!.avatarUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading avatar: $error');
                                      print('Avatar URL: ${user.avatarUrl}');
                                      return Icon(
                                        PlatformIcons.person,
                                        size: 40,
                                        color: Theme.of(context).primaryColor,
                                      );
                                    },
                                  )
                                : Icon(
                                    PlatformIcons.person,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                          ),
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Icon(
                              context.isIOS ? CupertinoIcons.camera_fill : Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user?.username ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Menu items
            AdaptiveListTile(
              leading: Icon(PlatformIcons.settings),
              title: const Text('Theme Settings'),
              trailing: Icon(
                context.isIOS
                    ? CupertinoIcons.chevron_right
                    : Icons.chevron_right,
              ),
              onTap: () {
                Navigator.pushNamed(context, '/theme-settings');
              },
            ),
            if (user?.emailVerified == false)
              AdaptiveListTile(
                leading: const Icon(Icons.verified_outlined),
                title: const Text('Verify Email'),
                subtitle: const Text('Your email is not verified'),
                trailing: Icon(
                  context.isIOS
                      ? CupertinoIcons.chevron_right
                      : Icons.chevron_right,
                ),
                onTap: () {
                  // TODO: Implement email verification
                },
              ),
            AdaptiveListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}