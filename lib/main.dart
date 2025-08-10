import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'shared/providers/habit_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/platform_provider.dart';
import 'shared/providers/navigation_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/community_provider.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for GraphQL caching
  await initHiveForFlutter();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlatformProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => CommunityProvider()),
      ],
      builder: (context, child) => const MyApp(),
    ),
  );
}

