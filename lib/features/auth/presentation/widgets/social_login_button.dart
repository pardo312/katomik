import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/platform/platform_service.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    this.iconColor,
    this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (context.isIOS) {
      return CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: iconColor ?? CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}