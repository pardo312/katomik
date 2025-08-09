import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LeaveCommunityDialog extends StatelessWidget {
  final String communityName;
  final VoidCallback onConfirm;

  const LeaveCommunityDialog({
    super.key,
    required this.communityName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Leave Community?'),
      content: Text(
        'Are you sure you want to leave $communityName? '
        'You can rejoin anytime, and your progress will be saved.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            'Leave',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}