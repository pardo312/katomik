import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../data/models/habit.dart';
import 'floating_phrase.dart';

class HabitWhySection extends StatelessWidget {
  final Habit habit;
  final AnimationController floatingAnimationController;
  final VoidCallback onAddContent;
  final List<Map<String, dynamic>> communityPhrases;
  
  const HabitWhySection({
    super.key,
    required this.habit,
    required this.floatingAnimationController,
    required this.onAddContent,
    required this.communityPhrases,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Porque tienes este habito?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: Stack(
              children: [
                if (habit.phrases.isEmpty && habit.images.isEmpty)
                  _buildEmptyState(context),
                ..._buildFloatingUserPhrases(context),
                ..._buildFloatingCommunityCards(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onAddContent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Text(
            'add',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildFloatingUserPhrases(BuildContext context) {
    final floatingElements = <Widget>[];
    
    final positions = [
      [const Offset(0.1, 0.1), const Offset(0.3, 0.2)],
      [const Offset(0.6, 0.2), const Offset(0.7, 0.1)],
      [const Offset(0.2, 0.3), const Offset(0.4, 0.4)],
      [const Offset(0.5, 0.05), const Offset(0.6, 0.15)],
      [const Offset(0.05, 0.4), const Offset(0.15, 0.5)],
      [const Offset(0.7, 0.35), const Offset(0.8, 0.45)],
      [const Offset(0.15, 0.25), const Offset(0.25, 0.35)],
    ];
    
    final colors = [
      Colors.white,
      Colors.black,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
    ];
    
    int positionIndex = 0;
    
    for (final phrase in habit.phrases) {
      final posIndex = positionIndex % positions.length;
      final bgColor = colors[positionIndex % colors.length];
      final textColor = bgColor == Colors.white ? Colors.black : Colors.white;
      
      floatingElements.add(
        FloatingPhrase(
          animation: floatingAnimationController,
          startPosition: positions[posIndex][0],
          endPosition: positions[posIndex][1],
          child: _buildPhraseCard(context, phrase, bgColor, textColor),
        ),
      );
      positionIndex++;
    }
    
    for (final imagePath in habit.images) {
      final posIndex = positionIndex % positions.length;
      
      floatingElements.add(
        FloatingPhrase(
          animation: floatingAnimationController,
          startPosition: positions[posIndex][0],
          endPosition: positions[posIndex][1],
          child: _buildImageCard(context, imagePath),
        ),
      );
      positionIndex++;
    }
    
    return floatingElements;
  }
  
  Widget _buildPhraseCard(BuildContext context, String phrase, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        phrase,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: Platform.isIOS ? '.SF UI Display' : 'Roboto',
        ),
      ),
    );
  }
  
  Widget _buildImageCard(BuildContext context, String imagePath) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Platform.isIOS ? CupertinoIcons.photo : Icons.image,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }
  
  List<Widget> _buildFloatingCommunityCards(BuildContext context) {
    return communityPhrases.asMap().entries.map((entry) {
      final index = entry.key;
      final phrase = entry.value;
      
      return FloatingPhrase(
        animation: floatingAnimationController,
        startPosition: Offset(0.1 + index * 0.3, 0.5 + index * 0.1),
        endPosition: Offset(0.2 + index * 0.3, 0.6 + index * 0.1),
        child: _buildCommunityCard(context, phrase),
      );
    }).toList();
  }
  
  Widget _buildCommunityCard(BuildContext context, Map<String, dynamic> phrase) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                phrase['avatar'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phrase['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'x${phrase['streak']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}