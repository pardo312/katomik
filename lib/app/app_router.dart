import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:katomik/features/auth/presentation/screens/login_screen.dart';
import 'package:katomik/features/auth/presentation/screens/register_screen.dart';
import 'package:katomik/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:katomik/features/habit/presentation/screens/habit_detail_screen.dart';
import 'package:katomik/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:katomik/shared/models/habit.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String addHabit = '/add-habit';
  static const String habitDetail = '/habit-detail';
  static const String themeSettings = '/theme-settings';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        addHabit: (context) => const HabitFormScreen(),
        themeSettings: (context) => const ThemeSettingsScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == habitDetail) {
      final habit = settings.arguments as Habit;
      return MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      );
    }
    return null;
  }

  static Route<dynamic>? onGenerateRouteCupertino(RouteSettings settings) {
    if (settings.name == habitDetail) {
      final habit = settings.arguments as Habit;
      return CupertinoPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      );
    }
    return null;
  }
}