class ExerciseType {
  static const String running = 'Running';
  static const String cycling = 'Cycling';
  static const String walking = 'Walking';
  static const String swimming = 'Swimming';
  static const String yoga = 'Yoga';
  static const String weightTraining = 'Weight Training';
  static const String cardio = 'Cardio';
  static const String dancing = 'Dancing';
  static const String hiking = 'Hiking';
  static const String other = 'Other';

  static List<String> getAllTypes() {
    return [
      running,
      cycling,
      walking,
      swimming,
      yoga,
      weightTraining,
      cardio,
      dancing,
      hiking,
      other,
    ];
  }

  static Map<String, String> getIcons() {
    return {
      running: '🏃‍♂️',
      cycling: '🚴‍♂️',
      walking: '🚶‍♂️',
      swimming: '🏊‍♂️',
      yoga: '🧘‍♀️',
      weightTraining: '💪',
      cardio: '❤️',
      dancing: '💃',
      hiking: '⛰️',
      other: '📝',
    };
  }
}

class CalorieCalculator {
  // Average calories burned per minute for different activities
  static const Map<String, double> caloriesPerMinute = {
    ExerciseType.running: 11.0,
    ExerciseType.cycling: 8.0,
    ExerciseType.walking: 4.0,
    ExerciseType.swimming: 9.0,
    ExerciseType.yoga: 3.0,
    ExerciseType.weightTraining: 6.0,
    ExerciseType.cardio: 10.0,
    ExerciseType.dancing: 7.0,
    ExerciseType.hiking: 8.0,
    ExerciseType.other: 5.0,
  };

  static int calculateCalories(String exerciseType, int durationMinutes) {
    final rate = caloriesPerMinute[exerciseType] ?? 5.0;
    return (rate * durationMinutes).round();
  }
}