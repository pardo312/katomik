import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/common/adaptive_widgets.dart';
import '../../../../core/platform/platform_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/platform/platform_icons.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/avatar_upload_mixin.dart';
import '../widgets/avatar_options_sheet.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/user_info_section.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AvatarUploadMixin {
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await LogoutConfirmationDialog.show(context);
    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
    }
  }

  void _showAvatarOptions() {
    AvatarOptionsSheet.show(
      context: context,
      onImageSourceSelected: handleAvatarUpload,
      onGoogleSync: handleSyncGoogleAvatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return AdaptiveScaffold(
      title: Text(AppLocalizations.of(context).profile),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ProfileAvatar(
                    avatarUrl: user?.avatarUrl,
                    isUploading: isUploading,
                    onTap: _showAvatarOptions,
                  ),
                  const SizedBox(height: 16),
                  UserInfoSection(user: user),
                ],
              ),
            ),
            const Divider(),
            AdaptiveListTile(
              leading: Icon(PlatformIcons.settings),
              title: Text(AppLocalizations.of(context).themeSettings),
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
                title: Text(AppLocalizations.of(context).verifyEmail),
                subtitle: Text(AppLocalizations.of(context).yourEmailNotVerified),
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
              title: Text(
                AppLocalizations.of(context).logout,
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