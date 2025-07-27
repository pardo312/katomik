import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'dart:io';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final selectedColor = themeProvider.selectedColor;
        
        if (Platform.isIOS) {
          return CupertinoApp(
            title: 'Katomik - Habit Tracker',
            theme: AppTheme.getCupertinoTheme(
              selectedColor,
              themeProvider.isDarkMode,
            ),
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        }
        
        return MaterialApp(
          title: 'Katomik - Habit Tracker',
          theme: AppTheme.getLightTheme(selectedColor),
          darkTheme: AppTheme.getDarkTheme(selectedColor),
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
