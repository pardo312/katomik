import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/platform/platform_icons.dart';
import 'user_avatar.dart';

class ProfileTabIcon extends StatelessWidget {
  final bool isActive;

  const ProfileTabIcon({
    super.key,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user?.avatarUrl != null) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
        ),
        child: ClipOval(
          child: UserAvatar(
            user: user,
            size: isActive ? 24 : 28,
          ),
        ),
      );
    }

    return Icon(
      isActive ? PlatformIcons.personActive : PlatformIcons.person,
    );
  }
}