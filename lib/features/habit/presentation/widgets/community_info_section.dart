import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../community/presentation/screens/community_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';

class CommunityInfoSection extends StatelessWidget {
  final String? communityId;
  final String? communityName;
  final VoidCallback? onMakePublic;

  const CommunityInfoSection({
    super.key,
    this.communityId,
    this.communityName,
    this.onMakePublic,
  });

  @override
  Widget build(BuildContext context) {
    if (communityId != null) {
      // This habit is associated with a community
      return _buildCommunityInfo(context);
    } else {
      // This is a private habit
      return _buildMakePublicOption(context);
    }
  }

  Widget _buildCommunityInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.person_3_fill,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  communityName ?? 'Community Habit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This habit is part of a community where members support each other.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityDetailScreen(
                      communityId: communityId!,
                      communityName: communityName ?? 'Community',
                    ),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.arrow_right_circle),
              label: const Text('View Community'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMakePublicOption(BuildContext context) {
    if (onMakePublic == null) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: onMakePublic,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.globe,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share with Community',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Make this habit public and let others join',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.arrow_right,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}