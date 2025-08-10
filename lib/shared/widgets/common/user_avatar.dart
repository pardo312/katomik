import 'package:flutter/material.dart';
import '../../../core/platform/platform_icons.dart';
import '../../models/user.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double size;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.user,
    this.size = 40,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl ?? user?.avatarUrl;
    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),
      child: ClipOval(
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(context),
              )
            : _buildPlaceholder(context),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Icon(
      PlatformIcons.person,
      size: size * 0.5,
      color: Theme.of(context).primaryColor,
    );
  }
}
