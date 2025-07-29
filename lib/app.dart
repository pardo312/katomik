import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/platform_provider.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, PlatformProvider>(
      builder: (context, themeProvider, platformProvider, child) {
        final selectedColor = themeProvider.selectedColor;
        
        if (platformProvider.isIOS) {
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