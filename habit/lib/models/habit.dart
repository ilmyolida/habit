class Habit {
  final int? id;
  final String name;
  final String category;
  final int color;
  final String icon;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final List<int> completedDays;
  final String frequency; // 'daily', 'weekly', 'monthly', 'custom'
  final int targetCount;
  final int currentCount;

  Habit({
    this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.isArchived,
    required this.createdAt,
    required this.completedDays,
    required this.frequency,
    required this.targetCount,
    required this.currentCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'icon': icon,
      'isActive': isActive ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'completedDays': completedDays.join(','),
      'frequency': frequency,
      'targetCount': targetCount,
      'currentCount': currentCount,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      icon: map['icon'],
      isActive: map['isActive'] == 1,
      isArchived: map['isArchived'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      completedDays: map['completedDays'].toString().isEmpty
          ? []
          : map['completedDays'].toString().split(',').map(int.parse).toList(),
      frequency: map['frequency'],
      targetCount: map['targetCount'],
      currentCount: map['currentCount'],
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? category,
    int? color,
    String? icon,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    List<int>? completedDays,
    String? frequency,
    int? targetCount,
    int? currentCount,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      completedDays: completedDays ?? this.completedDays,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}