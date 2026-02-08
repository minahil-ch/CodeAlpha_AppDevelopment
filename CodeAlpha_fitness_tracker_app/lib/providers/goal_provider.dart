import 'package:flutter/widgets.dart';
import '../models/goal.dart';
import '../helpers/database_helper.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Goal? _currentGoal;
  bool _isLoading = false;

  Goal? get currentGoal => _currentGoal;
  bool get isLoading => _isLoading;

  // Load current goal
  Future<void> loadCurrentGoal() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _currentGoal = await _dbHelper.getCurrentGoal();
    } catch (e) {
      // Handle error silently for now
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }



  // Set or update goal
  Future<void> setGoal(Goal goal) async {
    try {
      if (_currentGoal == null) {
        await _dbHelper.insertGoal(goal);
      } else {
        await _dbHelper.updateGoal(goal.copyWith(id: _currentGoal!.id));
      }
      await loadCurrentGoal(); // Refresh
    } catch (e) {
      print('Error setting goal: $e');
      rethrow;
    }
  }

  // Calculate progress percentages for today
  Future<Map<String, double>> getTodayProgress() async {
    final today = DateTime.now();
    
    final totalSteps = await _dbHelper.getTotalStepsForDate(today);
    final totalCalories = await _dbHelper.getTotalCaloriesForDate(today);
    final totalActiveMinutes = await _dbHelper.getTotalActiveMinutesForDate(today);
    
    if (_currentGoal == null) {
      return {
        'stepsProgress': 0.0,
        'caloriesProgress': 0.0,
        'activeMinutesProgress': 0.0,
      };
    }
    
    return {
      'stepsProgress': (_currentGoal!.stepGoal > 0) 
          ? (totalSteps / _currentGoal!.stepGoal).clamp(0.0, 1.0)
          : 0.0,
      'caloriesProgress': (_currentGoal!.calorieGoal > 0)
          ? (totalCalories / _currentGoal!.calorieGoal).clamp(0.0, 1.0)
          : 0.0,
      'activeMinutesProgress': (_currentGoal!.activeMinuteGoal > 0)
          ? (totalActiveMinutes / _currentGoal!.activeMinuteGoal).clamp(0.0, 1.0)
          : 0.0,
    };
  }

  // Get remaining values to reach goals
  Future<Map<String, int>> getRemainingToGoal() async {
    final today = DateTime.now();
    
    final totalSteps = await _dbHelper.getTotalStepsForDate(today);
    final totalCalories = await _dbHelper.getTotalCaloriesForDate(today);
    final totalActiveMinutes = await _dbHelper.getTotalActiveMinutesForDate(today);
    
    if (_currentGoal == null) {
      return {
        'stepsRemaining': 0,
        'caloriesRemaining': 0,
        'activeMinutesRemaining': 0,
      };
    }
    
    return {
      'stepsRemaining': (_currentGoal!.stepGoal - totalSteps).clamp(0, double.infinity).toInt(),
      'caloriesRemaining': (_currentGoal!.calorieGoal - totalCalories).clamp(0, double.infinity).toInt(),
      'activeMinutesRemaining': (_currentGoal!.activeMinuteGoal - totalActiveMinutes).clamp(0, double.infinity).toInt(),
    };
  }
}