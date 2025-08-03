import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';

class GovernanceMemberCard extends StatelessWidget {
  final int rank;
  final String name;
  final String avatar;
  final int streak;
  final bool isCreator;

  const GovernanceMemberCard({
    super.key,
    required this.rank,
    required this.name,
    required this.avatar,
    required this.streak,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank == 1 ? Colors.amber : Colors.grey.shade200,
          width: rank == 1 ? 2 : 1,
        ),
        boxShadow: rank == 1
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rank == 1
                  ? Colors.amber.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank == 1
                  ? Icon(
                      CupertinoIcons.star_fill,
                      color: Colors.amber,
                      size: 20,
                    )
                  : Text(
                      rank.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 20)),
            ),
          ),

          const SizedBox(width: 12),

          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isCreator) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Creator',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Voting member',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.flame_fill,
                    size: 16,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    streak.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                'days',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
