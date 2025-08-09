# Community Module Structure

## Refactored Organization

### Screens (Simplified)
- `community_detail_screen_refactored.dart` (~200 lines, down from 808)
- `discover_communities_screen_refactored.dart` (~150 lines)
- `governance_screen_refactored.dart` (~180 lines)

### View Models
- `community_detail_view_model.dart` - Business logic for community details
- `discover_view_model.dart` - Search and filter logic
- `governance_view_model.dart` - Governance state management

### Tabs (Extracted Components)
- `leaderboard_tab.dart` - Leaderboard display with timeframe selector
- `stats_tab.dart` - Community statistics display
- `about_tab.dart` - Community information display
- `voting_members_tab.dart` - Governance members list
- `proposals_tab.dart` - Active and historical proposals

### Widgets (Small, Focused Components)
- `community_header.dart` - Reusable header component
- `community_member_status.dart` - Member status and actions
- `community_icon.dart` - Icon rendering
- `community_badges.dart` - Category and difficulty badges
- `community_stats.dart` - Statistics display
- `community_tags.dart` - Tag rendering
- `loading_state.dart` - Loading indicator
- `error_state.dart` - Error display
- `empty_state.dart` - Empty state display

### Utils
- `message_handler.dart` - Platform-specific message handling

### Dialogs
- `leave_community_dialog.dart` - Leave confirmation
- `join_community_dialog.dart` - Join community
- `create_proposal_dialog.dart` - Create governance proposal

### Services (Decomposed)
- `base_service.dart` - Common GraphQL operations
- `search_service.dart` - Search operations
- `details_service.dart` - Details and leaderboard
- `membership_service.dart` - Join/leave operations
- `publishing_service.dart` - Make habits public
- `governance_service.dart` - Proposals and voting

### Repository Pattern
- `community_repository.dart` - Data operations interface
- `cache/community_cache.dart` - Caching layer

### Constants & Validators
- `community_constants.dart` - Configuration values
- `community_validators.dart` - Input validation

### Hooks
- `use_community_search.dart` - Search state management
- `use_debounce.dart` - Debounced operations
- `use_pagination.dart` - Pagination logic

## Key Improvements

1. **File Size Reduction**: Main screen reduced from 808 to ~200 lines
2. **Single Responsibility**: Each file has one clear purpose
3. **Reusability**: Components can be used across different screens
4. **Testability**: View models and services are easily testable
5. **Maintainability**: Changes are localized to specific files
6. **Performance**: Caching layer reduces API calls
7. **Clarity**: Self-documenting code without comments