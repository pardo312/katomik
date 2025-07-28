import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

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
      _getIconData(iconName),
      size: size,
      color: color,
    );
  }

  IconData _getIconData(String name) {
    final icons = {
      // Default
      'science': Platform.isIOS ? CupertinoIcons.lab_flask : Icons.science,
      
      // Health & Fitness
      'water': Platform.isIOS ? CupertinoIcons.drop : Icons.water_drop,
      'run': Platform.isIOS ? CupertinoIcons.person_2 : Icons.directions_run,
      'gym': Platform.isIOS ? CupertinoIcons.sportscourt : Icons.fitness_center,
      'bike': Platform.isIOS ? CupertinoIcons.car : Icons.pedal_bike,
      'yoga': Platform.isIOS ? CupertinoIcons.person : Icons.self_improvement,
      'heart': Platform.isIOS ? CupertinoIcons.heart_fill : Icons.favorite,
      'sleep': Platform.isIOS ? CupertinoIcons.bed_double : Icons.bedtime,
      
      // Productivity
      'book': Platform.isIOS ? CupertinoIcons.book_fill : Icons.menu_book,
      'write': Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
      'code': Platform.isIOS ? CupertinoIcons.chevron_left_slash_chevron_right : Icons.code,
      'work': Platform.isIOS ? CupertinoIcons.briefcase_fill : Icons.work,
      'study': Platform.isIOS ? CupertinoIcons.book : Icons.school,
      'time': Platform.isIOS ? CupertinoIcons.clock_fill : Icons.access_time,
      
      // Lifestyle
      'food': Platform.isIOS ? CupertinoIcons.square_favorites_alt : Icons.restaurant,
      'coffee': Platform.isIOS ? CupertinoIcons.circle_fill : Icons.coffee,
      'music': Platform.isIOS ? CupertinoIcons.music_note : Icons.music_note,
      'art': Platform.isIOS ? CupertinoIcons.paintbrush_fill : Icons.palette,
      'photo': Platform.isIOS ? CupertinoIcons.camera_fill : Icons.camera_alt,
      'game': Platform.isIOS ? CupertinoIcons.game_controller_solid : Icons.sports_esports,
      
      // Mental Health
      'meditate': Platform.isIOS ? CupertinoIcons.sun_min_fill : Icons.self_improvement,
      'journal': Platform.isIOS ? CupertinoIcons.book : Icons.book,
      'mood': Platform.isIOS ? CupertinoIcons.smiley : Icons.mood,
      
      // Learning
      'language': Platform.isIOS ? CupertinoIcons.globe : Icons.language,
      'chess': Platform.isIOS ? CupertinoIcons.square_grid_2x2 : Icons.grid_on,
      'guitar': Platform.isIOS ? CupertinoIcons.music_note_2 : Icons.music_note,
      'piano': Platform.isIOS ? CupertinoIcons.music_note_list : Icons.piano,
      
      // Other
      'star': Platform.isIOS ? CupertinoIcons.star_fill : Icons.star,
      'check': Platform.isIOS ? CupertinoIcons.check_mark_circled_solid : Icons.check_circle,
      'flag': Platform.isIOS ? CupertinoIcons.flag_fill : Icons.flag,
      'chart': Platform.isIOS ? CupertinoIcons.chart_bar_fill : Icons.bar_chart,
    };

    return icons[name] ?? (Platform.isIOS ? CupertinoIcons.lab_flask : Icons.science);
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