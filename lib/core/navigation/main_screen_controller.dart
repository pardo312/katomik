import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:katomik/shared/providers/navigation_provider.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import 'package:katomik/shared/providers/auth_provider.dart';
import 'package:katomik/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:katomik/core/platform/platform_service.dart';
import 'package:katomik/core/navigation/main_screen_tab_config.dart';

class MainScreenController {
  static void initializeHabits(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final habitProvider = context.read<HabitProvider>();
      final userId = authProvider.user?.id;

      if (userId != null) {
        habitProvider.initializeForUser(userId);
      }
    });
  }

  static void handleTabChange({
    required BuildContext context,
    required int index,
    required Function(int) updateIndex,
  }) {
    updateIndex(index);
    
    if (index == MainScreenTabConfig.homeTabIndex) {
      final navProvider = context.read<NavigationProvider>();
      navProvider.showHomeFabIfNeeded();
    }
  }

  static void navigateToHabitForm(BuildContext context) {
    final route = context.platform.isIOS
        ? CupertinoPageRoute(builder: (_) => const HabitFormScreen())
        : MaterialPageRoute(builder: (_) => const HabitFormScreen());
    Navigator.push(context, route);
  }

  static bool shouldShowFab({
    required int currentIndex,
    required NavigationProvider navProvider,
  }) {
    return currentIndex == MainScreenTabConfig.homeTabIndex && navProvider.showHomeFab;
  }
}