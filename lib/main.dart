import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'dart:io';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Katomik - Habit Tracker',
        theme: AppTheme.cupertinoTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
    
    return MaterialApp(
      title: 'Katomik - Habit Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
