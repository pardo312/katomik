import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:katomik/app/app.dart';
import 'package:katomik/shared/providers/habit_provider.dart';
import 'package:katomik/shared/providers/theme_provider.dart';

void main() {
  testWidgets('Katomik app smoke test', (WidgetTester tester) async {
    // Create providers
    final habitProvider = HabitProvider();
    final themeProvider = ThemeProvider();

    // Build our app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: habitProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that app loads and shows Katomik title
    expect(find.text('Katomik'), findsOneWidget);

    // Verify that the home tab is selected by default
    expect(find.text('Home'), findsOneWidget);

    // Verify that empty state is shown when no habits exist
    final emptyStateTexts = [
      'No habits yet',
      'Start building better habits today!',
    ];
    
    for (final text in emptyStateTexts) {
      expect(find.text(text), findsOneWidget);
    }
  });
}