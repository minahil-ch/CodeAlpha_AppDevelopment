class Activity {
  final int? id;
  final String type;
  final int duration; // in minutes
  final int calories;
  final DateTime dateTime;
  final double? distance; // in kilometers (optional)
  final String? notes;

  Activity({
    this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.dateTime,
    this.distance,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
      'distance': distance,
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      type: map['type'],
      duration: map['duration'],
      calories: map['calories'],
      dateTime: DateTime.parse(map['dateTime']),
      distance: map['distance'],
      notes: map['notes'],
    );
  }

  Activity copyWith({
    int? id,
    String? type,
    int? duration,
    int? calories,
    DateTime? dateTime,
    double? distance,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
    );
  }
}