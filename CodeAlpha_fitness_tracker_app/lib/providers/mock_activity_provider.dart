import 'package:flutter/widgets.dart';
import '../models/activity.dart';
import '../helpers/mock_database_helper.dart';

class MockActivityProvider with ChangeNotifier {
  final MockDatabaseHelper _dbHelper = MockDatabaseHelper();
  List<Activity> _activities = [];
  bool _isLoading = false;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  // Get all activities
  Future<void> loadActivities() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _activities = await _dbHelper.getActivities();
    } catch (e) {
      // Handle error silently for now
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Get activities for a specific date
  Future<List<Activity>> getActivitiesForDate(DateTime date) async {
    return await _dbHelper.getActivitiesByDate(date);
  }

  // Get activities for a week
  Future<List<Activity>> getActivitiesForWeek(DateTime startDate) async {
    return await _dbHelper.getActivitiesByWeek(startDate);
  }

  // Add new activity
  Future<void> addActivity(Activity activity) async {
    try {
      await _dbHelper.insertActivity(activity);
      await loadActivities(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  // Update existing activity
  Future<void> updateActivity(Activity activity) async {
    try {
      await _dbHelper.updateActivity(activity);
      await loadActivities(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  // Delete activity
  Future<void> deleteActivity(int id) async {
    try {
      await _dbHelper.deleteActivity(id);
      await loadActivities(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  // Get today's statistics
  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now();
    final activities = await getActivitiesForDate(today);
    
    int totalDuration = 0;
    int totalCalories = 0;
    
    for (var activity in activities) {
      totalDuration += activity.duration;
      totalCalories += activity.calories;
    }
    
    final steps = await _dbHelper.getTotalStepsForDate(today);
    
    return {
      'activitiesCount': activities.length,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'totalSteps': steps,
    };
  }

  // Get weekly statistics
  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    
    List<Map<String, dynamic>> weeklyData = [];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final activities = await getActivitiesForDate(date);
      
      int totalCalories = 0;
      int totalDuration = 0;
      int totalSteps = await _dbHelper.getTotalStepsForDate(date);
      
      for (var activity in activities) {
        totalCalories += activity.calories;
        totalDuration += activity.duration;
      }
      
      weeklyData.add({
        'date': date,
        'calories': totalCalories,
        'duration': totalDuration,
        'steps': totalSteps,
        'activitiesCount': activities.length,
      });
    }
    
    return weeklyData;
  }
}