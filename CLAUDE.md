# Katomik - Habit Tracker Architecture

## Project Overview

Katomik is a cross-platform habit tracking application built with Flutter. It has evolved from a simple local habit tracker to a full-featured social habit tracking platform with community features, backend synchronization, and user authentication. The app helps users build better routines through habit tracking, community engagement, and social accountability.

## Tech Stack

### Frontend
- **Flutter SDK**: ^3.8.1
- **State Management**: Provider (^6.1.2)
- **Local Database**: SQLite (sqflite: ^2.3.3+2) - for offline caching
- **Charts**: fl_chart (^0.69.0)
- **Calendars**: table_calendar (^3.1.2)
- **Design System**: Material Design 3 with adaptive iOS/Android UI

### Backend Integration
- **GraphQL Client**: graphql_flutter (^5.1.2)
- **Authentication**: JWT with flutter_secure_storage (^9.2.2)
- **JWT Decoder**: jwt_decoder (^2.0.1)
- **Google Sign-In**: google_sign_in (^6.2.2)
- **HTTP Client**: http (^1.2.0)
- **Image Picker**: image_picker (^1.1.2)

## Architecture Overview

```
lib/
├── core/                          # Core utilities and shared code
│   ├── constants/                 # App-wide constants
│   │   └── app_colors.dart        # Color constants
│   ├── platform/                  # Platform abstraction layer
│   │   ├── platform_service.dart  # Platform detection service
│   │   ├── platform_icons.dart    # Centralized icon mappings
│   │   ├── platform_constants.dart # Platform-specific values
│   │   └── platform_extensions.dart # Helper extensions
│   ├── theme/                     # Theme configuration
│   │   └── app_theme.dart         # Material and Cupertino themes
│   └── utils/                     # Utility functions
│       ├── color_utils.dart       # Color manipulation
│       ├── date_utils.dart        # Date manipulation helpers
│       └── platform_messages.dart # Platform-specific messages
│
├── config/                        # Configuration
│   └── graphql_config.dart        # GraphQL client configuration
│
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   ├── habit.dart             # Enhanced habit model
│   │   ├── habit_completion.dart  # Habit completion model
│   │   └── user.dart              # User model
│   └── services/                  # Services
│       ├── auth_service.dart      # Authentication service
│       ├── community_service.dart # Community features service
│       ├── database_service.dart  # SQLite database service (legacy)
│       ├── graphql_client.dart    # GraphQL client wrapper
│       ├── habit_service.dart     # Habit management service
│       └── profile_service.dart   # User profile service
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── screens/
│   │   │   ├── login_screen.dart # Login with email/Google
│   │   │   └── register_screen.dart # User registration
│   │   └── widgets/
│   │       └── auth_wrapper.dart  # Auth state management wrapper
│   │
│   ├── community/                 # Community features
│   │   ├── screens/
│   │   │   ├── community_detail_screen.dart # Community details
│   │   │   ├── discover_communities_screen.dart # Browse communities
│   │   │   └── governance_screen.dart # Community governance
│   │   └── widgets/
│   │       ├── community_card.dart
│   │       ├── community_filters.dart
│   │       ├── community_search_bar.dart
│   │       ├── community_stats_card.dart
│   │       ├── create_proposal_dialog.dart
│   │       ├── governance_member_card.dart
│   │       ├── join_community_dialog.dart
│   │       ├── leaderboard_list.dart
│   │       ├── make_habit_public_dialog.dart
│   │       └── proposal_card.dart
│   │
│   ├── habit/                     # Habit management feature
│   │   ├── add_habit/
│   │   │   ├── add_habit_screen.dart # Create/edit habits
│   │   │   └── widgets/
│   │   │       ├── color_picker.dart
│   │   │       ├── icon_picker.dart
│   │   │       ├── images_section.dart
│   │   │       └── phrases_section.dart
│   │   ├── habit_detail/
│   │   │   ├── habit_detail_screen.dart # Habit details & calendar
│   │   │   └── widgets/
│   │   │       ├── community_info_section.dart
│   │   │       ├── floating_phrase.dart
│   │   │       ├── habit_calendar_grid.dart
│   │   │       ├── habit_detail_header.dart
│   │   │       ├── habit_weekly_tracker.dart
│   │   │       └── make_habit_public_dialog.dart
│   │   └── widgets/
│   │       └── habit_icon.dart    # Habit icon component
│   │
│   ├── home/                      # Home feature
│   │   ├── screens/
│   │   │   └── home_screen.dart   # Main habits list
│   │   └── widgets/
│   │       ├── community_button.dart # Quick community access
│   │       ├── date_header.dart   # Date display header
│   │       ├── empty_state.dart   # Empty habits state
│   │       ├── habit_row.dart     # Habit list item
│   │       ├── streak_header.dart # Streak counter
│   │       └── weekly_habit_tracker.dart # Weekly view
│   │
│   ├── profile/                   # User profile feature
│   │   ├── screens/
│   │   │   └── profile_screen.dart # User profile & settings
│   │   └── widgets/
│   │       ├── avatar_options_sheet.dart
│   │       ├── avatar_upload_mixin.dart
│   │       ├── logout_confirmation_dialog.dart
│   │       ├── profile_avatar.dart
│   │       └── user_info_section.dart
│   │
│   ├── settings/                  # Settings feature
│   │   └── screens/
│   │       └── theme_settings_screen.dart # Theme customization
│   │
│   └── statistics/                # Statistics feature
│       └── screens/
│           └── statistics_screen.dart # Charts & analytics
│
├── providers/                     # State management
│   ├── auth_provider.dart         # Authentication state
│   ├── community_provider.dart    # Community features state
│   ├── habit_provider.dart        # Habits state management
│   ├── navigation_provider.dart   # Navigation state
│   ├── platform_provider.dart     # Platform state provider
│   └── theme_provider.dart        # Theme state management
│
├── shared/                        # Shared components
│   └── widgets/
│       ├── adaptive_navigation.dart # Adaptive navigation
│       ├── adaptive_widgets.dart    # Platform-adaptive widgets
│       ├── profile_tab_icon.dart   # Profile tab with avatar
│       └── user_avatar.dart        # User avatar component
│
├── app.dart                       # App configuration
├── main.dart                      # Entry point
└── main_screen.dart               # Main navigation shell
```

## Key Architectural Patterns

### 1. Backend-First Architecture
- **Pattern**: GraphQL-first with local caching
- **Implementation**: All data flows through GraphQL services, with SQLite for offline support
- **Authentication**: JWT-based auth with refresh tokens stored in secure storage
- **Benefits**: Real-time sync, multi-device support, social features

### 2. Platform Abstraction Layer
- **Pattern**: Strategy Pattern with Dependency Injection
- **Location**: `lib/core/platform/`
- **Purpose**: Centralize all platform-specific logic
- **Components**:
  - `PlatformService`: Abstract interface for platform detection
  - `PlatformIcons`: Centralized icon mappings
  - `PlatformConstants`: Platform-specific values
  - `PlatformExtensions`: Helper methods on BuildContext

### 3. Feature-First Organization
- **Pattern**: Feature-based module structure
- **Location**: `lib/features/`
- **New Features**:
  - Authentication (login, register, OAuth)
  - Community (discover, join, governance)
  - Profile management
  - Enhanced habit features (phrases, images, reminders)

### 4. Service Layer Architecture
- **Pattern**: Service layer for backend communication
- **Services**:
  - `AuthService`: Handles authentication flows (login, register, Google Sign-In)
  - `HabitService`: Manages habits via GraphQL
  - `CommunityService`: Community features and governance
  - `ProfileService`: User profile management
  - `DatabaseService`: Legacy local storage (being phased out)

### 5. Provider State Management
- **Pattern**: ChangeNotifier with Provider
- **Providers**:
  - `AuthProvider`: Authentication state and user session
  - `HabitProvider`: Habits and completions state
  - `CommunityProvider`: Community browsing and membership
  - `ThemeProvider`: Theme selection and dark mode
  - `PlatformProvider`: Platform information
  - `NavigationProvider`: Navigation state (FAB visibility)

### 6. Adaptive UI Components
- **Pattern**: Factory Pattern for UI components
- **Components**: Same as before, with enhanced profile tab

## Data Models

### User Model (New)
```dart
class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String timezone;
  final bool isActive;
  final bool emailVerified;
  final String? googleId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Enhanced Habit Model
```dart
class Habit {
  final String? id;           // UUID from server
  final String name;
  final List<String> phrases; // Motivational phrases
  final List<String> images;  // Habit images
  final DateTime createdDate;
  final DateTime? updatedDate;
  final String color;
  final String icon;
  final bool isActive;
  final bool isFromCommunity; // Joined from community
  final bool isPublic;        // Shared with community
  final String? communityId;
  final String? communityName;
  final String? reminderTime; // Daily reminder
  final List<int>? reminderDays; // Days of week
}
```

### HabitCompletion Model
```dart
class HabitCompletion {
  final String? id;       // Server ID
  final String habitId;   // References Habit.id
  final DateTime date;
  final bool isCompleted;
  final String? note;     // Completion note
}
```

## GraphQL Integration

### Authentication Flow
1. **Login/Register**: Sends credentials to GraphQL
2. **Token Storage**: JWT tokens stored in flutter_secure_storage
3. **Auto-refresh**: Refresh token used when access token expires
4. **Google OAuth**: Integrated with backend OAuth flow

### Data Synchronization
1. **Real-time Sync**: All habit operations sync with backend
2. **Offline Support**: Local SQLite cache (being implemented)
3. **Conflict Resolution**: Server-authoritative model

### Community Features
- Browse and search communities
- Join/leave communities
- Make habits public
- Community governance (proposals, voting)
- Leaderboards and statistics

## Navigation Structure

```
MainScreen (Bottom Navigation - 4 tabs)
├── Home Tab
│   ├── HomeScreen (habit list)
│   ├── AddHabitScreen (via FAB)
│   └── HabitDetailScreen
├── Analytics Tab
│   └── StatisticsScreen
├── Community Tab
│   ├── DiscoverCommunitiesScreen
│   ├── CommunityDetailScreen
│   └── GovernanceScreen
└── Profile Tab
    ├── ProfileScreen
    └── ThemeSettingsScreen
```

## Authentication & Security

### Security Features
1. **Secure Token Storage**: flutter_secure_storage for JWT tokens
2. **Token Refresh**: Automatic token refresh on expiration
3. **Logout**: Clears all tokens and cached data
4. **Google Sign-In**: OAuth 2.0 integration

### Auth Flow
1. **App Start**: AuthProvider checks for valid token
2. **AuthWrapper**: Shows login or main app based on auth state
3. **Protected Routes**: All GraphQL queries include auth header
4. **Session Management**: Automatic session refresh

## State Management Flow

1. **App Start**: Initialize all providers
2. **Auth Check**: AuthProvider validates session
3. **Data Loading**: 
   - HabitProvider loads user habits from GraphQL
   - CommunityProvider loads user communities
4. **Real-time Updates**: GraphQL mutations update server and local state
5. **UI Updates**: Providers notify listeners for UI updates

## Platform-Specific Implementations

### iOS (Cupertino)
- CupertinoApp with iOS-specific theming
- CupertinoNavigationBar
- iOS-style page transitions
- Custom FAB for iOS (positioned button)

### Android (Material)
- MaterialApp with Material 3 theming
- Standard AppBar with elevation
- Material page transitions
- Native FAB implementation

## New Features & Capabilities

### 1. Community System
- Browse habit communities by category/difficulty
- Join communities to adopt habits
- Share personal habits with community
- Community governance with proposals
- Leaderboards and competition

### 2. Enhanced Habits
- Motivational phrases for each habit
- Image attachments
- Reminder scheduling
- Community integration
- Public/private visibility

### 3. User Profiles
- Profile photos (upload/camera)
- Bio and personal info
- Timezone support
- Account statistics
- Social features

### 4. Backend Sync
- Real-time data synchronization
- Multi-device support
- Cloud backup
- Social features

## Development Guidelines

### 1. GraphQL Operations
- Define queries/mutations in service files
- Handle errors gracefully
- Use proper typing for responses
- Implement offline fallbacks

### 2. Authentication
- Always check auth state before protected operations
- Handle token refresh transparently
- Clear sensitive data on logout
- Test OAuth flows thoroughly

### 3. State Management
- Keep providers focused and single-purpose
- Use service layer for backend operations
- Handle loading and error states
- Notify listeners appropriately

### 4. Community Features
- Validate user permissions
- Handle community state changes
- Update local state after operations
- Show appropriate loading indicators

## Testing Strategy

1. **Unit Tests**
   - Models and data transformations
   - Service layer methods
   - Provider business logic

2. **Widget Tests**
   - Adaptive components
   - Feature screens
   - Authentication flows

3. **Integration Tests**
   - Full user flows
   - GraphQL operations
   - Community interactions

## Future Enhancements

1. **Offline Mode**: Complete offline support with sync queue
2. **Push Notifications**: Habit reminders and community updates
3. **Advanced Analytics**: ML-powered insights and predictions
4. **Challenges**: Time-based community challenges
5. **Achievements**: Gamification with badges and rewards
6. **Social Feed**: Share progress and motivate others
7. **Habit Templates**: Curated habit suggestions
8. **Voice Notes**: Audio journal for habits
9. **Wearable Integration**: Apple Watch / Wear OS apps

## Migration Notes

The app is transitioning from local-only to cloud-first:
- SQLite is being phased out for primary storage
- All new features use GraphQL
- Legacy code marked for removal
- Backward compatibility maintained during transition

## Environment Configuration

### Development
- Backend URL: `http://localhost:3000/graphql`
- Android emulator: `http://10.0.2.2:3000/graphql`
- iOS simulator: `http://localhost:3000/graphql`

### Production
- Update `GraphQLConfig.baseUrl` with production endpoint
- Configure proper SSL certificates
- Set up proper token rotation
- Enable crash reporting

## Security Considerations

1. **Token Security**: Tokens stored in secure storage only
2. **API Security**: All requests authenticated
3. **Data Privacy**: User data encrypted in transit
4. **OAuth Security**: Proper OAuth 2.0 implementation
5. **Input Validation**: Client and server-side validation