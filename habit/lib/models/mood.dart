enum MoodLevel {
  terrible('Berbat', 0, Color(0xFFE53935)),
  bad('Kotu', 1, Color(0xFFFF7043)),
  neutral('Notr', 2, Color(0xFFFFA726)),
  good('Iyi', 3, Color(0xFF66BB6A)),
  great('Harika', 4, Color(0xFF26A69A));

  final String label;
  final int value;
  final Color color;
  
  const MoodLevel(this.label, this.value, this.color);
  
  static MoodLevel fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
  
  static MoodLevel fromLabel(String label) {
    return values.firstWhere((e) => e.label == label);
  }
}

class MoodEntry {
  final int? id;
  final DateTime date;
  final MoodLevel mood;
  final List<String> activities;
  final List<String> tags;
  final String? note;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.activities,
    required this.tags,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.value,
      'activities': activities.join(','),
      'tags': tags.join(','),
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      mood: MoodLevel.fromValue(map['mood']),
      activities: map['activities'].toString().isEmpty
          ? []
          : map['activities'].toString().split(','),
      tags: map['tags'].toString().isEmpty
          ? []
          : map['tags'].toString().split(','),
      note: map['note'],
    );
  }
}