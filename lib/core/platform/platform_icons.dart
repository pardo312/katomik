import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'platform_service.dart';

class PlatformIcons {
  static final PlatformService _platform = DefaultPlatformService();
  
  // Navigation Icons
  static IconData get home => _platform.isCupertino 
      ? CupertinoIcons.house 
      : Icons.home_outlined;
      
  static IconData get homeActive => _platform.isCupertino 
      ? CupertinoIcons.house_fill 
      : Icons.home;
      
  static IconData get analytics => _platform.isCupertino 
      ? CupertinoIcons.chart_bar 
      : Icons.analytics_outlined;
      
  static IconData get analyticsActive => _platform.isCupertino 
      ? CupertinoIcons.chart_bar_fill 
      : Icons.analytics;
      
  static IconData get globe => _platform.isCupertino 
      ? CupertinoIcons.globe 
      : Icons.public_outlined;
      
  static IconData get globeActive => _platform.isCupertino 
      ? CupertinoIcons.globe 
      : Icons.public;
      
  static IconData get person => _platform.isCupertino 
      ? CupertinoIcons.person 
      : Icons.person_outline;
      
  static IconData get personActive => _platform.isCupertino 
      ? CupertinoIcons.person_fill 
      : Icons.person;
  
  // Action Icons
  static IconData get add => _platform.isCupertino 
      ? CupertinoIcons.add 
      : Icons.add;
      
  static IconData get edit => _platform.isCupertino 
      ? CupertinoIcons.pencil 
      : Icons.edit;
      
  static IconData get delete => _platform.isCupertino 
      ? CupertinoIcons.delete 
      : Icons.delete;
      
  static IconData get check => _platform.isCupertino 
      ? CupertinoIcons.checkmark 
      : Icons.check;
      
  static IconData get checkCircle => _platform.isCupertino 
      ? CupertinoIcons.check_mark_circled_solid 
      : Icons.check_circle;
  
  // Common Icons
  static IconData get sparkles => _platform.isCupertino 
      ? CupertinoIcons.sparkles 
      : Icons.auto_awesome;
      
  static IconData get description => _platform.isCupertino 
      ? CupertinoIcons.doc_text 
      : Icons.description;
  
  // Habit Icons Mapping
  static final Map<String, IconData> _habitIconsMap = {
    'science': _platform.isCupertino ? CupertinoIcons.lab_flask : Icons.science,
    'water': _platform.isCupertino ? CupertinoIcons.drop : Icons.water_drop,
    'run': _platform.isCupertino ? CupertinoIcons.person_2 : Icons.directions_run,
    'gym': _platform.isCupertino ? CupertinoIcons.sportscourt : Icons.fitness_center,
    'bike': _platform.isCupertino ? CupertinoIcons.car : Icons.pedal_bike,
    'yoga': _platform.isCupertino ? CupertinoIcons.person : Icons.self_improvement,
    'heart': _platform.isCupertino ? CupertinoIcons.heart_fill : Icons.favorite,
    'sleep': _platform.isCupertino ? CupertinoIcons.bed_double : Icons.bedtime,
    'book': _platform.isCupertino ? CupertinoIcons.book_fill : Icons.menu_book,
    'write': _platform.isCupertino ? CupertinoIcons.pencil : Icons.edit,
    'code': _platform.isCupertino ? CupertinoIcons.chevron_left_slash_chevron_right : Icons.code,
    'work': _platform.isCupertino ? CupertinoIcons.briefcase_fill : Icons.work,
    'study': _platform.isCupertino ? CupertinoIcons.book : Icons.school,
    'time': _platform.isCupertino ? CupertinoIcons.clock_fill : Icons.access_time,
    'food': _platform.isCupertino ? CupertinoIcons.square_favorites_alt : Icons.restaurant,
    'coffee': _platform.isCupertino ? CupertinoIcons.circle_fill : Icons.coffee,
    'music': _platform.isCupertino ? CupertinoIcons.music_note : Icons.music_note,
    'art': _platform.isCupertino ? CupertinoIcons.paintbrush_fill : Icons.palette,
    'photo': _platform.isCupertino ? CupertinoIcons.camera_fill : Icons.camera_alt,
    'game': _platform.isCupertino ? CupertinoIcons.game_controller_solid : Icons.sports_esports,
    'meditate': _platform.isCupertino ? CupertinoIcons.sun_min_fill : Icons.self_improvement,
    'journal': _platform.isCupertino ? CupertinoIcons.book : Icons.book,
    'mood': _platform.isCupertino ? CupertinoIcons.smiley : Icons.mood,
    'language': _platform.isCupertino ? CupertinoIcons.globe : Icons.language,
    'chess': _platform.isCupertino ? CupertinoIcons.square_grid_2x2 : Icons.grid_on,
    'guitar': _platform.isCupertino ? CupertinoIcons.music_note_2 : Icons.music_note,
    'piano': _platform.isCupertino ? CupertinoIcons.music_note_list : Icons.piano,
    'star': _platform.isCupertino ? CupertinoIcons.star_fill : Icons.star,
    'flag': _platform.isCupertino ? CupertinoIcons.flag_fill : Icons.flag,
    'chart': _platform.isCupertino ? CupertinoIcons.chart_bar_fill : Icons.bar_chart,
  };
  
  static IconData getHabitIcon(String name) {
    return _habitIconsMap[name] ?? (_platform.isCupertino ? CupertinoIcons.lab_flask : Icons.science);
  }
  
  // Factory method for dynamic icon selection
  static IconData adaptive({
    required IconData material,
    required IconData cupertino,
  }) {
    return _platform.isCupertino ? cupertino : material;
  }
}

// Extension for easier icon access
extension IconExtensions on BuildContext {
  IconData adaptiveIcon({
    required IconData material,
    required IconData cupertino,
  }) {
    return DefaultPlatformService().isCupertino ? cupertino : material;
  }
}