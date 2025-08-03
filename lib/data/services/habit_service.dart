import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/habit.dart';
import '../../config/graphql_config.dart';

class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  // Queries
  static const String myHabitsQuery = r'''
    query MyHabits {
      myHabits {
        id
        name
        phrases
        color
        icon
        isActive
        isPublic
        reminderTime
        reminderDays
        createdAt
        updatedAt
        isFromCommunity
        communityId
        community {
          id
          habit {
            name
          }
        }
      }
    }
  ''';

  static const String habitQuery = r'''
    query GetHabit($id: ID!) {
      habit(id: $id) {
        id
        name
        phrases
        color
        icon
        isActive
        isPublic
        reminderTime
        reminderDays
        createdAt
        updatedAt
        isFromCommunity
        communityId
        community {
          id
          habit {
            name
          }
        }
      }
    }
  ''';

  static const String habitCompletionsQuery = r'''
    query HabitCompletions($habitId: ID!, $startDate: String!, $endDate: String!) {
      habitCompletions(habitId: $habitId, startDate: $startDate, endDate: $endDate) {
        id
        habit {
          id
        }
        date
        isCompleted
        note
        createdAt
      }
    }
  ''';

  // Mutations
  static const String createHabitMutation = r'''
    mutation CreateHabit($input: CreateHabitInput!) {
      createHabit(input: $input) {
        id
        name
        phrases
        color
        icon
        isActive
        isPublic
        reminderTime
        reminderDays
        createdAt
        updatedAt
      }
    }
  ''';

  static const String updateHabitMutation = r'''
    mutation UpdateHabit($id: ID!, $input: UpdateHabitInput!) {
      updateHabit(id: $id, input: $input) {
        id
        name
        phrases
        color
        icon
        isActive
        isPublic
        reminderTime
        reminderDays
        createdAt
        updatedAt
      }
    }
  ''';

  static const String deleteHabitMutation = r'''
    mutation DeleteHabit($id: ID!) {
      deleteHabit(id: $id)
    }
  ''';

  static const String recordCompletionMutation = r'''
    mutation RecordHabitCompletion($input: CreateHabitCompletionInput!) {
      recordHabitCompletion(input: $input) {
        id
        habit {
          id
        }
        date
        isCompleted
        note
        createdAt
      }
    }
  ''';

  // Service Methods
  Future<List<Habit>> getUserHabits() async {
    print('HabitService: Getting user habits...');
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(myHabitsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print('HabitService: GraphQL Exception: ${result.exception}');
      throw Exception('Failed to fetch habits: ${result.exception}');
    }

    print('HabitService: Query result data: ${result.data}');
    final List<dynamic> habitsData = result.data?['myHabits'] ?? [];
    print('HabitService: Found ${habitsData.length} habits');
    return habitsData.map((h) => Habit.fromServerJson(h)).toList();
  }

  Future<Habit> getHabit(String id) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(habitQuery),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch habit: ${result.exception}');
    }

    return Habit.fromServerJson(result.data!['habit']);
  }

  Future<Habit> createHabit({
    required String name,
    required List<String> phrases,
    required String color,
    required String icon,
    String? reminderTime,
    List<int>? reminderDays,
    bool isPrivate = true,
  }) async {
    print('HabitService: Creating habit "$name"...');
    final client = await GraphQLConfig.getClient();
    
    final variables = {
      'input': {
        'name': name,
        'color': color,
        'icon': icon,
        'isPrivate': isPrivate,
        if (reminderTime != null) 'reminderTime': reminderTime,
        if (reminderDays != null) 'reminderDays': reminderDays,
      },
    };
    print('HabitService: Create variables: $variables');
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(createHabitMutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      print('HabitService: Create habit exception: ${result.exception}');
      throw Exception('Failed to create habit: ${result.exception}');
    }

    print('HabitService: Create result: ${result.data}');
    final createdHabit = Habit.fromServerJson(result.data!['createHabit']);
    
    // For now, return the created habit with phrases included locally
    // The backend's CreateHabitInput doesn't support phrases yet
    // TODO: Update backend to support phrases in CreateHabitInput
    return createdHabit.copyWith(phrases: phrases);
  }

  Future<Habit> updateHabit({
    required String id,
    String? name,
    List<String>? phrases,
    String? color,
    String? icon,
    bool? isActive,
    String? reminderTime,
    List<int>? reminderDays,
  }) async {
    final client = await GraphQLConfig.getClient();
    
    final Map<String, dynamic> input = {};
    if (name != null) input['name'] = name;
    if (phrases != null) input['phrases'] = phrases;
    if (color != null) input['color'] = color;
    if (icon != null) input['icon'] = icon;
    if (isActive != null) input['isActive'] = isActive;
    if (reminderTime != null) input['reminderTime'] = reminderTime;
    if (reminderDays != null) input['reminderDays'] = reminderDays;
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateHabitMutation),
        variables: {
          'id': id,
          'input': input,
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to update habit: ${result.exception}');
    }

    return Habit.fromServerJson(result.data!['updateHabit']);
  }

  Future<bool> deleteHabit(String id) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(deleteHabitMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to delete habit: ${result.exception}');
    }

    return result.data!['deleteHabit'] == true;
  }

  Future<Map<String, dynamic>> recordCompletion({
    required String habitId,
    required DateTime date,
    bool isCompleted = true,
    String? note,
  }) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(recordCompletionMutation),
        variables: {
          'input': {
            'habitId': habitId,
            'date': date.toIso8601String().split('T')[0],
            'isCompleted': isCompleted,
            if (note != null) 'note': note,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to record completion: ${result.exception}');
    }

    return result.data!['recordHabitCompletion'];
  }

  Future<List<Map<String, dynamic>>> getCompletions({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(habitCompletionsQuery),
        variables: {
          'habitId': habitId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to fetch completions: ${result.exception}');
    }

    final List<dynamic> completions = result.data?['habitCompletions'] ?? [];
    return completions.cast<Map<String, dynamic>>();
  }
}