import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'habits.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            created_date TEXT NOT NULL,
            color TEXT NOT NULL,
            icon TEXT NOT NULL DEFAULT 'science',
            is_active INTEGER NOT NULL DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE completions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
            UNIQUE(habit_id, date)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE habits ADD COLUMN icon TEXT NOT NULL DEFAULT "science"');
        }
      },
    );
  }

  // Habit CRUD operations
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_date DESC',
    );
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Soft delete (mark as inactive)
  Future<int> deactivateHabit(int id) async {
    final db = await database;
    return await db.update(
      'habits',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // HabitCompletion CRUD operations
  Future<int> insertOrUpdateCompletion(HabitCompletion completion) async {
    final db = await database;
    return await db.insert(
      'completions',
      completion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => HabitCompletion.fromMap(maps[i]));
  }

  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'completions',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return List.generate(maps.length, (i) => HabitCompletion.fromMap(maps[i]));
  }

  Future<HabitCompletion?> getCompletionForHabitAndDate(
      int habitId, DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'completions',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
    if (maps.isNotEmpty) {
      return HabitCompletion.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteCompletion(int id) async {
    final db = await database;
    return await db.delete(
      'completions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics queries
  Future<int> getStreakForHabit(int habitId) async {
    final db = await database;
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      
      final result = await db.query(
        'completions',
        where: 'habit_id = ? AND date = ? AND is_completed = 1',
        whereArgs: [habitId, dateStr],
      );
      
      if (result.isEmpty) {
        break;
      }
      streak++;
    }
    
    return streak;
  }

  Future<Map<String, double>> getCompletionRateForHabit(
      int habitId, int days) async {
    final db = await database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final completions = await db.rawQuery('''
      SELECT COUNT(*) as completed_days
      FROM completions
      WHERE habit_id = ? 
        AND date BETWEEN ? AND ?
        AND is_completed = 1
    ''', [
      habitId,
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0]
    ]);
    
    final completedDays = completions.first['completed_days'] as int;
    final completionRate = (completedDays / days) * 100;
    
    return {
      'completedDays': completedDays.toDouble(),
      'totalDays': days.toDouble(),
      'completionRate': completionRate,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}