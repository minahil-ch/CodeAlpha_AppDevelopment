class Goal {
  final int? id;
  final int stepGoal;
  final int calorieGoal;
  final int activeMinuteGoal;
  final DateTime createdAt;

  Goal({
    this.id,
    required this.stepGoal,
    required this.calorieGoal,
    required this.activeMinuteGoal,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stepGoal': stepGoal,
      'calorieGoal': calorieGoal,
      'activeMinuteGoal': activeMinuteGoal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      stepGoal: map['stepGoal'],
      calorieGoal: map['calorieGoal'],
      activeMinuteGoal: map['activeMinuteGoal'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Goal copyWith({
    int? id,
    int? stepGoal,
    int? calorieGoal,
    int? activeMinuteGoal,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      stepGoal: stepGoal ?? this.stepGoal,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      activeMinuteGoal: activeMinuteGoal ?? this.activeMinuteGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}