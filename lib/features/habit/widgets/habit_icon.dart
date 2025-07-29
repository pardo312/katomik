import 'package:flutter/material.dart';
import '../../../core/platform/platform_icons.dart';
import '../../../shared/widgets/adaptive_widgets.dart';

class HabitIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const HabitIcon({
    super.key,
    required this.iconName,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      PlatformIcons.getHabitIcon(iconName),
      size: size,
      color: color,
    );
  }


  static List<String> get availableIcons => [
    'science',
    'water',
    'run',
    'gym',
    'bike',
    'yoga',
    'heart',
    'sleep',
    'book',
    'write',
    'code',
    'work',
    'study',
    'time',
    'food',
    'coffee',
    'music',
    'art',
    'photo',
    'game',
    'meditate',
    'journal',
    'mood',
    'language',
    'chess',
    'guitar',
    'piano',
    'star',
    'check',
    'flag',
    'chart',
  ];
}