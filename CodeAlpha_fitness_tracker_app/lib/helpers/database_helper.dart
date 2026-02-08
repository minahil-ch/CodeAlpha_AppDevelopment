import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/activity.dart';
import '../models/goal.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create activities table
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        dateTime TEXT NOT NULL,
        distance REAL,
        notes TEXT
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stepGoal INTEGER NOT NULL DEFAULT 10000,
        calorieGoal INTEGER NOT NULL DEFAULT 2000,
        activeMinuteGoal INTEGER NOT NULL DEFAULT 30,
        createdAt TEXT NOT NULL
      )
    ''');

    // Insert default goals
    await db.insert('goals', {
      'stepGoal': 10000,
      'calorieGoal': 2000,
      'activeMinuteGoal': 30,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Activity CRUD operations
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('activities');
    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<List<Activity>> getActivitiesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<List<Activity>> getActivitiesByWeek(DateTime startDate) async {
    final db = await database;
    final endDate = startDate.add(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<List<Activity>> getActivitiesByMonth(DateTime startDate) async {
    final db = await database;
    final endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);

    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal CRUD operations
  Future<Goal?> getCurrentGoal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Goal.fromMap(maps.first);
  }

  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // Utility methods for statistics
  Future<int> getTotalStepsForDate(DateTime date) async {
    // For now, we'll estimate steps based on activities
    // In a real app, this would integrate with step counting sensors
    final activities = await getActivitiesByDate(date);
    int totalSteps = 0;
    
    for (var activity in activities) {
      // Estimate steps based on activity type and duration
      switch (activity.type) {
        case 'Walking':
        case 'Hiking':
          totalSteps += activity.duration * 100; // ~100 steps per minute
          break;
        case 'Running':
          totalSteps += activity.duration * 150; // ~150 steps per minute
          break;
        case 'Cycling':
          totalSteps += activity.duration * 50; // ~50 steps per minute (pedaling)
          break;
        default:
          totalSteps += activity.duration * 75; // average for other activities
      }
    }
    
    return totalSteps;
  }

  Future<int> getTotalCaloriesForDate(DateTime date) async {
    final activities = await getActivitiesByDate(date);
    int total = 0;
    for (var activity in activities) {
      total += activity.calories;
    }
    return total;
  }

  Future<int> getTotalActiveMinutesForDate(DateTime date) async {
    final activities = await getActivitiesByDate(date);
    int total = 0;
    for (var activity in activities) {
      total += activity.duration;
    }
    return total;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}