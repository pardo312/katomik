import 'package:flutter/material.dart';
import 'package:katomik/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

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
      title: Text(AppLocalizations.of(context).leaveCommunity),
      content: Text(
        'Are you sure you want to leave $communityName? '
        'You can rejoin anytime, and your progress will be saved.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            'Leave',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}