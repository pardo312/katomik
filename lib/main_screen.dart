import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katomik/shared/widgets/adaptive_navigation.dart';
import 'package:katomik/core/platform/platform_service.dart';
import 'package:katomik/shared/providers/navigation_provider.dart';
import 'package:katomik/core/navigation/main_screen_tab_config.dart';
import 'package:katomik/core/navigation/main_screen_controller.dart';
import 'package:katomik/shared/widgets/ios_floating_action_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MainScreenController.initializeHabits(context);
  }

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = MainScreenTabConfig.getTabs();

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final showFab = MainScreenController.shouldShowFab(
          currentIndex: _currentIndex,
          navProvider: navProvider,
        );

        if (context.platform.isIOS) {
          return _IOSLayout(
            tabs: tabs,
            currentIndex: _currentIndex,
            showFab: showFab,
            onTabChanged: (index) => MainScreenController.handleTabChange(
              context: context,
              index: index,
              updateIndex: _updateIndex,
            ),
            onAddPressed: () => MainScreenController.navigateToAddHabit(context),
          );
        }

        return _AndroidLayout(
          tabs: tabs,
          currentIndex: _currentIndex,
          showFab: showFab,
          onTabChanged: (index) => MainScreenController.handleTabChange(
            context: context,
            index: index,
            updateIndex: _updateIndex,
          ),
          onAddPressed: () => MainScreenController.navigateToAddHabit(context),
        );
      },
    );
  }
}

class _IOSLayout extends StatelessWidget {
  final List<AdaptiveTabItem> tabs;
  final int currentIndex;
  final bool showFab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddPressed;

  const _IOSLayout({
    required this.tabs,
    required this.currentIndex,
    required this.showFab,
    required this.onTabChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AdaptiveTabScaffold(
          tabs: tabs,
          currentIndex: currentIndex,
          onTabChanged: onTabChanged,
        ),
        if (showFab)
          Positioned(
            bottom: 100,
            right: 16,
            child: IOSFloatingActionButton(
              onPressed: onAddPressed,
            ),
          ),
      ],
    );
  }
}

class _AndroidLayout extends StatelessWidget {
  final List<AdaptiveTabItem> tabs;
  final int currentIndex;
  final bool showFab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddPressed;

  const _AndroidLayout({
    required this.tabs,
    required this.currentIndex,
    required this.showFab,
    required this.onTabChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveTabScaffold(
        tabs: tabs,
        currentIndex: currentIndex,
        onTabChanged: onTabChanged,
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: onAddPressed,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}