import '../models/activity.dart';
import '../models/goal.dart';

class MockDatabaseHelper {
  static final MockDatabaseHelper _instance = MockDatabaseHelper._internal();
  factory MockDatabaseHelper() => _instance;
  MockDatabaseHelper._internal();

  // Mock data storage
  final List<Activity> _activities = [];
  Goal? _currentGoal;

  // Initialize with sample data
  void initializeSampleData() {
    if (_activities.isEmpty) {
      // Add some sample activities
      _activities.addAll([
        Activity(
          id: 1,
          type: 'Running',
          duration: 30,
          calories: 300,
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Activity(
          id: 2,
          type: 'Cycling',
          duration: 45,
          calories: 400,
          dateTime: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Activity(
          id: 3,
          type: 'Yoga',
          duration: 60,
          calories: 200,
          dateTime: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);
    }

    if (_currentGoal == null) {
      _currentGoal = Goal(
        id: 1,
        stepGoal: 10000,
        calorieGoal: 2000,
        activeMinuteGoal: 60,
        createdAt: DateTime.now(),
      );
    }
  }

  // Activity CRUD operations
  Future<int> insertActivity(Activity activity) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate async
    final newId = _activities.isEmpty ? 1 : (_activities.last.id ?? 0) + 1;
    _activities.add(activity.copyWith(id: newId));
    return newId;
  }

  Future<List<Activity>> getActivities() async {
    await Future.delayed(const Duration(milliseconds: 100));
    initializeSampleData();
    return List.from(_activities)..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<List<Activity>> getActivitiesByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    initializeSampleData();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _activities.where((activity) {
      return activity.dateTime.isAfter(startOfDay) && 
             activity.dateTime.isBefore(endOfDay);
    }).toList();
  }

  Future<List<Activity>> getActivitiesByWeek(DateTime startDate) async {
    await Future.delayed(const Duration(milliseconds: 50));
    initializeSampleData();
    final endDate = startDate.add(const Duration(days: 7));
    
    return _activities.where((activity) {
      return activity.dateTime.isAfter(startDate) && 
             activity.dateTime.isBefore(endDate);
    }).toList();
  }

  Future<int> updateActivity(Activity activity) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
      return 1;
    }
    return 0;
  }

  Future<int> deleteActivity(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _activities.removeWhere((activity) => activity.id == id);
    return 1;
  }

  // Goal CRUD operations
  Future<Goal?> getCurrentGoal() async {
    await Future.delayed(const Duration(milliseconds: 50));
    initializeSampleData();
    return _currentGoal;
  }

  Future<int> insertGoal(Goal goal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentGoal = goal.copyWith(id: 1);
    return 1;
  }

  Future<int> updateGoal(Goal goal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentGoal = goal;
    return 1;
  }

  // Utility methods for statistics
  Future<int> getTotalStepsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final activities = await getActivitiesByDate(date);
    int totalSteps = 0;
    
    for (var activity in activities) {
      switch (activity.type) {
        case 'Walking':
        case 'Hiking':
          totalSteps += activity.duration * 100;
          break;
        case 'Running':
          totalSteps += activity.duration * 150;
          break;
        case 'Cycling':
          totalSteps += activity.duration * 50;
          break;
        default:
          totalSteps += activity.duration * 75;
      }
    }
    
    return totalSteps;
  }

  Future<int> getTotalCaloriesForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final activities = await getActivitiesByDate(date);
    int total = 0;
    for (var activity in activities) {
      total += activity.calories;
    }
    return total;
  }

  Future<int> getTotalActiveMinutesForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final activities = await getActivitiesByDate(date);
    int total = 0;
    for (var activity in activities) {
      total += activity.duration;
    }
    return total;
  }
}