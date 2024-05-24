class HabitFields {
  static final List<String> values = [id, name, completed];

  static const String id = '_id';
  static const String name = 'name';
  static const String completed = 'completed';
}

class Habit {
  final int? id;
  final String name;
  final bool completed;

  const Habit({
    this.id,
    required this.name,
    required this.completed,
  });

  Habit copy({
    int? id,
    String? name,
    bool? completed,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        completed: completed ?? this.completed,
      );

  static Habit fromJson(Map<String, Object?> json) => Habit(
        id: json[HabitFields.id] as int?,
        name: json[HabitFields.name] as String,
        completed: json[HabitFields.completed] == 1,
      );

  Map<String, dynamic> toJson() => {
      HabitFields.id: id,
      HabitFields.name: name,
      HabitFields.completed: completed ? 1 : 0,
  };
}
