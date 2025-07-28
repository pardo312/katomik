import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'main_screen.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

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
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        }
        
        return MaterialApp(
          title: 'Katomik - Habit Tracker',
          theme: AppTheme.getLightTheme(selectedColor),
          darkTheme: AppTheme.getDarkTheme(selectedColor),
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}