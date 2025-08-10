import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:katomik/shared/providers/theme_provider.dart';
import 'package:katomik/shared/providers/platform_provider.dart';
import 'package:katomik/shared/providers/auth_provider.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import 'package:katomik/shared/providers/community_provider.dart';
import 'package:katomik/core/theme/app_theme.dart';
import 'package:katomik/features/auth/presentation/widgets/auth_wrapper.dart';
import 'app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Connect providers after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final habitProvider = context.read<HabitProvider>();
      final communityProvider = context.read<CommunityProvider>();
      authProvider.setProviders(habitProvider, communityProvider);
    });
  }

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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('es', 'ES'),
            ],
            routes: AppRouter.routes,
            onGenerateRoute: AppRouter.onGenerateRouteCupertino,
          );
        }

        return MaterialApp(
          title: 'Katomik - Habit Tracker',
          theme: AppTheme.getLightTheme(selectedColor),
          darkTheme: AppTheme.getDarkTheme(selectedColor),
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          routes: AppRouter.routes,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
