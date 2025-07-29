import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/platform_provider.dart';
import 'providers/navigation_provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlatformProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      builder: (context, child) => const MyApp(),
    ),
  );
}

