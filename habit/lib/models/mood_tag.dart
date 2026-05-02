class MoodTag {
  final int? id;
  final String name;
  final int order;
  final bool isActive;

  MoodTag({
    this.id,
    required this.name,
    required this.order,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory MoodTag.fromMap(Map<String, dynamic> map) {
    return MoodTag(
      id: map['id'],
      name: map['name'],
      order: map['order'],
      isActive: map['isActive'] == 1,
    );
  }
}

// Default tags from images
List<MoodTag> defaultMoodTags = [
  MoodTag(name: 'Okuma', order: 0, isActive: true),
  MoodTag(name: 'Muzik', order: 1, isActive: true),
  MoodTag(name: 'Yemek yapma', order: 2, isActive: true),
  MoodTag(name: 'TV izleme', order: 3, isActive: true),
  MoodTag(name: 'Oyun', order: 4, isActive: true),
  MoodTag(name: 'Temizlik', order: 5, isActive: true),
  MoodTag(name: 'Alisveris', order: 6, isActive: true),
  MoodTag(name: 'Haberler', order: 7, isActive: true),
  MoodTag(name: 'Sosyal medya', order: 8, isActive: true),
  MoodTag(name: 'Ogrenme', order: 9, isActive: true),
];