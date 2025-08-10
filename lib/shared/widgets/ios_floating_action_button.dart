import 'package:flutter/cupertino.dart';

class IOSFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const IOSFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = CupertinoIcons.add,
    this.size = 56,
    this.backgroundColor = CupertinoColors.activeBlue,
    this.iconColor = CupertinoColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size / 2,
        ),
      ),
    );
  }
}