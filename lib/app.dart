import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:katomik/features/habit/screens/habit_detail_screen_new.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/platform_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/widgets/auth_wrapper.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/habit/screens/add_habit_screen.dart';
import 'features/settings/screens/theme_settings_screen.dart';
import 'data/models/habit.dart';

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
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/add-habit': (context) => const AddHabitScreen(),
              '/theme-settings': (context) => const ThemeSettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/habit-detail') {
                final habit = settings.arguments as Habit;
                return CupertinoPageRoute(
                  builder: (context) => HabitDetailScreen(habit: habit),
                );
              }
              return null;
            },
          );
        }

        return MaterialApp(
          title: 'Katomik - Habit Tracker',
          theme: AppTheme.getLightTheme(selectedColor),
          darkTheme: AppTheme.getDarkTheme(selectedColor),
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/add-habit': (context) => const AddHabitScreen(),
            '/theme-settings': (context) => const ThemeSettingsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/habit-detail') {
              final habit = settings.arguments as Habit;
              return MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habit: habit),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
