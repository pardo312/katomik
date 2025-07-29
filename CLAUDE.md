# Katomik - Habit Tracker Architecture

## Project Overview

Katomik is a cross-platform habit tracking application built with Flutter. It helps users build better routines through simple and effective habit tracking, with features like daily tracking, streak monitoring, statistics visualization, and offline support.

## Tech Stack

- **Flutter SDK**: ^3.8.1
- **State Management**: Provider (^6.1.2)
- **Database**: SQLite (sqflite: ^2.4.1)
- **Charts**: fl_chart (^0.70.0)
- **Calendars**: table_calendar (^3.1.2)
- **Design System**: Material Design 3 with adaptive iOS/Android UI

## Architecture Overview

```
lib/
├── core/                          # Core utilities and shared code
│   ├── constants/                 # App-wide constants
│   ├── platform/                  # Platform abstraction layer
│   │   ├── platform_service.dart  # Platform detection service
│   │   ├── platform_icons.dart    # Centralized icon mappings
│   │   ├── platform_constants.dart # Platform-specific values
│   │   └── platform_extensions.dart # Helper extensions
│   ├── theme/                     # Theme configuration
│   │   └── app_theme.dart         # Material and Cupertino themes
│   └── utils/                     # Utility functions
│       └── date_utils.dart        # Date manipulation helpers
│
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   ├── habit.dart             # Habit model
│   │   └── habit_completion.dart  # Habit completion model
│   └── services/                  # Services
│       └── database_service.dart  # SQLite database service
│
├── features/                      # Feature modules
│   ├── habit/                     # Habit management feature
│   │   ├── screens/
│   │   │   ├── add_habit_screen.dart    # Create/edit habits
│   │   │   └── habit_detail_screen.dart # Habit details & calendar
│   │   └── widgets/
│   │       └── habit_icon.dart          # Habit icon component
│   │
│   ├── home/                      # Home feature
│   │   ├── screens/
│   │   │   └── home_screen.dart         # Main habits list
│   │   └── widgets/
│   │       ├── date_header.dart         # Date display header
│   │       ├── empty_state.dart         # Empty habits state
│   │       ├── habit_row.dart           # Habit list item
│   │       ├── streak_header.dart       # Streak counter
│   │       └── weekly_habit_tracker.dart # Weekly view
│   │
│   ├── settings/                  # Settings feature
│   │   └── screens/
│   │       └── theme_settings_screen.dart # Theme customization
│   │
│   └── statistics/                # Statistics feature
│       └── screens/
│           └── statistics_screen.dart    # Charts & analytics
│
├── providers/                     # State management
│   ├── habit_provider.dart        # Habits state management
│   ├── platform_provider.dart     # Platform state provider
│   └── theme_provider.dart        # Theme state management
│
├── shared/                        # Shared components
│   └── widgets/
│       ├── adaptive_navigation.dart # Adaptive navigation
│       └── adaptive_widgets.dart    # Platform-adaptive widgets
│
├── app.dart                       # App configuration
├── main.dart                      # Entry point
└── main_screen.dart               # Main navigation shell
```

## Key Architectural Patterns

### 1. Platform Abstraction Layer
- **Pattern**: Strategy Pattern with Dependency Injection
- **Location**: `lib/core/platform/`
- **Purpose**: Centralize all platform-specific logic, eliminating scattered `Platform.isIOS` checks
- **Components**:
  - `PlatformService`: Abstract interface for platform detection
  - `PlatformIcons`: Centralized icon mappings
  - `PlatformConstants`: Platform-specific values (spacing, radius, etc.)
  - `PlatformExtensions`: Helper methods on BuildContext

### 2. Feature-First Organization
- **Pattern**: Feature-based module structure
- **Location**: `lib/features/`
- **Purpose**: Group related screens, widgets, and logic by feature
- **Benefits**: Better scalability, easier navigation, clear boundaries

### 3. Repository Pattern
- **Pattern**: Repository pattern with service layer
- **Location**: `lib/data/services/database_service.dart`
- **Purpose**: Abstract data persistence logic
- **Implementation**: Singleton DatabaseService handling SQLite operations

### 4. Provider State Management
- **Pattern**: ChangeNotifier with Provider
- **Location**: `lib/providers/`
- **Providers**:
  - `HabitProvider`: Manages habits and completions state
  - `ThemeProvider`: Handles theme selection and dark mode
  - `PlatformProvider`: Provides platform information app-wide

### 5. Adaptive UI Components
- **Pattern**: Factory Pattern for UI components
- **Location**: `lib/shared/widgets/adaptive_widgets.dart`
- **Components**:
  - `AdaptiveScaffold`: Platform-specific page structure
  - `AdaptiveButton`: iOS/Android button styles
  - `AdaptiveIcon`: Platform-aware icons
  - `AdaptiveListTile`: Native list tiles
  - `AdaptiveAppBar`: Platform-specific app bars

## Data Models

### Habit Model
```dart
class Habit {
  final int? id;
  final String name;
  final String description;
  final DateTime createdDate;
  final String color;      // Hex color string
  final String icon;       // Icon identifier
  final bool isActive;
}
```

### HabitCompletion Model
```dart
class HabitCompletion {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool isCompleted;
}
```

## Database Schema

### habits table
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `name`: TEXT NOT NULL
- `description`: TEXT NOT NULL
- `created_date`: TEXT NOT NULL (ISO8601)
- `color`: TEXT NOT NULL
- `icon`: TEXT NOT NULL DEFAULT 'science'
- `is_active`: INTEGER NOT NULL DEFAULT 1

### completions table
- `id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `habit_id`: INTEGER NOT NULL (FK → habits.id)
- `date`: TEXT NOT NULL (ISO8601)
- `is_completed`: INTEGER NOT NULL DEFAULT 0
- UNIQUE constraint on (habit_id, date)

## Key Features Implementation

### 1. Habit Management
- Create habits with name, description, color, and icon
- Edit existing habits
- Toggle habit completion for any date
- View habit details with calendar

### 2. Streak Tracking
- Calculate current streak based on consecutive completions
- Display streak in habit list
- Reset streak on missed days

### 3. Statistics & Analytics
- Overall completion rate
- Weekly/monthly charts using fl_chart
- Per-habit completion statistics
- Visual progress indicators

### 4. Theme System
- Material You color theming
- 10 predefined color options
- Dark mode support
- Platform-specific styling (iOS/Android)

### 5. Offline Support
- All data stored locally in SQLite
- No network dependencies
- Instant data access
- Automatic database migrations

## Navigation Structure

```
MainScreen (Bottom Navigation)
├── Home Tab
│   ├── HomeScreen (habit list)
│   ├── AddHabitScreen
│   └── HabitDetailScreen
├── Analytics Tab
│   └── StatisticsScreen
├── Network Tab (placeholder)
└── Profile Tab
    └── ThemeSettingsScreen
```

## State Management Flow

1. **App Start**: Initialize providers in main.dart
2. **Data Loading**: HabitProvider loads habits from DatabaseService
3. **UI Updates**: Widgets consume providers using Consumer/context.watch
4. **User Actions**: UI calls provider methods
5. **State Changes**: Providers update state and notify listeners
6. **Persistence**: Changes saved to SQLite database

## Platform-Specific Implementations

### iOS (Cupertino)
- CupertinoApp with iOS-specific theming
- CupertinoNavigationBar
- CupertinoIcons throughout
- iOS-style page transitions
- Minimal elevation/shadows

### Android (Material)
- MaterialApp with Material 3 theming
- Standard AppBar with elevation
- Material Icons
- Material page transitions
- Card-based layouts with shadows

## Best Practices & Conventions

1. **Code Organization**
   - Feature-first folder structure
   - Single responsibility principle
   - Clear separation of concerns

2. **State Management**
   - Immutable state updates
   - Async operations in providers
   - Error handling at provider level

3. **UI/UX**
   - Adaptive components for platform consistency
   - Responsive layouts
   - Accessibility considerations
   - Consistent spacing using PlatformConstants

4. **Performance**
   - Lazy loading of data
   - Efficient widget rebuilds
   - Singleton services
   - Cached calculations (streaks, stats)

5. **Testing Strategy**
   - Unit tests for models and services
   - Widget tests for UI components
   - Integration tests for critical flows

## Development Guidelines

1. **Adding New Features**
   - Create feature folder under `lib/features/`
   - Add screens and widgets subfolders
   - Create provider if state management needed
   - Use adaptive widgets for UI

2. **Platform-Specific Code**
   - Use PlatformService instead of direct Platform checks
   - Add icons to PlatformIcons
   - Use PlatformConstants for spacing/styling
   - Create adaptive widgets for new components

3. **Database Changes**
   - Increment database version
   - Add migration logic in onUpgrade
   - Update models and services
   - Test migration thoroughly

4. **Theme Updates**
   - Modify AppTheme class
   - Ensure both Material and Cupertino themes updated
   - Test in light and dark modes
   - Verify on both platforms

## Future Enhancements

1. **Cloud Sync**: Add Firebase for data backup
2. **Reminders**: Local notifications for habits
3. **Social Features**: Share progress, challenges
4. **Advanced Analytics**: Insights, predictions
5. **Widgets**: Home screen widgets
6. **Watch App**: Apple Watch / Wear OS support
7. **Export Data**: CSV/PDF export functionality
8. **Habit Templates**: Pre-made habit suggestions

## Troubleshooting

1. **Database Issues**
   - Check migration logic
   - Verify schema matches models
   - Clear app data if corrupted

2. **Platform Rendering**
   - Verify platform detection working
   - Check adaptive widget implementations
   - Test on both iOS and Android

3. **State Updates**
   - Ensure notifyListeners() called
   - Check Consumer widget usage
   - Verify provider scope

4. **Performance**
   - Profile widget rebuilds
   - Check for unnecessary computations
   - Optimize database queries