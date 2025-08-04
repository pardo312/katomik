import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/habit.dart';
import '../../config/graphql_config.dart';
import '../../core/logging/logging.dart';

class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();
  
  static final _logger = Logger.forModule('HabitService');

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
        isFromCommunity
        communityId
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
        isFromCommunity
        communityId
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
    _logger.info('Getting user habits');
    final client = await GraphQLConfig.getClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(myHabitsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      NetworkLogger.logGraphQLOperation(
        operation: 'query',
        operationName: 'MyHabits',
        error: result.exception,
      );
      throw Exception('Failed to fetch habits: ${result.exception}');
    }

    NetworkLogger.logGraphQLOperation(
      operation: 'query',
      operationName: 'MyHabits',
      result: result.data,
    );
    final List<dynamic> habitsData = result.data?['myHabits'] ?? [];
    _logger.info('Found ${habitsData.length} habits');
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
    _logger.info('Creating habit', metadata: {
      'name': name,
      'phrasesCount': phrases.length,
      'isPrivate': isPrivate,
    });
    final client = await GraphQLConfig.getClient();
    
    // TODO: Backend bug - isPrivate is not being converted to isPublic
    // The backend ignores isPrivate and uses database default isPublic: true
    // This needs to be fixed in communities.service.ts createPrivateHabit method
    final variables = {
      'input': {
        'name': name,
        'color': color,
        'icon': icon,
        'isPrivate': isPrivate,
        'phrases': phrases,
        if (reminderTime != null) 'reminderTime': reminderTime,
        if (reminderDays != null) 'reminderDays': reminderDays,
      },
    };
    _logger.debug('Create variables: $variables');
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(createHabitMutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      NetworkLogger.logGraphQLOperation(
        operation: 'mutation',
        operationName: 'CreateHabit',
        variables: variables,
        error: result.exception,
      );
      throw Exception('Failed to create habit: ${result.exception}');
    }

    NetworkLogger.logGraphQLOperation(
      operation: 'mutation',
      operationName: 'CreateHabit',
      variables: variables,
      result: result.data,
    );
    final createdHabit = Habit.fromServerJson(result.data!['createHabit']);
    
    _logger.info('Habit created successfully', metadata: {
      'habitId': createdHabit.id,
    });
    
    return createdHabit;
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