# Internationalization (i18n) Guide

This directory contains all localization files for the Katomik app.

## Supported Languages

- English (en) - Default language
- Spanish (es)

## File Structure

- `app_localizations.dart` - Abstract base class defining all translatable strings
- `app_localizations_en.dart` - English translations
- `app_localizations_es.dart` - Spanish translations

## Usage in Code

Import the localizations:
```dart
import 'package:katomik/l10n/app_localizations.dart';
```

Access localized strings:
```dart
AppLocalizations.of(context)?.login ?? 'Login'
```

## Adding New Translations

1. Add the new string getter to `app_localizations.dart`:
```dart
String get newString;
```

2. Add English translation to `app_localizations_en.dart`:
```dart
@override
String get newString => 'English text';
```

3. Add Spanish translation to `app_localizations_es.dart`:
```dart
@override
String get newString => 'Texto en español';
```

## Adding New Languages

1. Create a new file `app_localizations_[lang_code].dart`
2. Extend `AppLocalizations` class
3. Implement all required string getters
4. Add the locale to `supportedLocales` in `app_localizations.dart`
5. Update the `lookupAppLocalizations` function to handle the new language

## Testing Language Changes

To test different languages on iOS Simulator:
1. Settings > General > Language & Region > iPhone Language

To test different languages on Android Emulator:
1. Settings > System > Languages & Input > Languages

## Common Patterns

### Parameterized Strings
For strings with dynamic values:
```dart
String daysAgo(int days) => '$days days ago';
```

### Fallback Pattern
Always provide a fallback value:
```dart
AppLocalizations.of(context)?.key ?? 'Fallback text'
```

## Validation Messages

Validation messages are handled through localized validator functions in:
`lib/features/auth/utils/auth_validator.dart`

Use the getter methods that accept BuildContext:
```dart
validator: AuthValidator.getEmailValidator(context)
```