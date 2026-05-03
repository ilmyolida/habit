class Category {
  final int? id;
  final String name;
  final String icon;
  final int color;
  final String type; // 'habit', 'expense', 'mood_activity'

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      type: map['type'],
    );
  }
}

// Default categories
List<Category> defaultHabitCategories = [
  Category(name: 'Diger', icon: 'more_horiz', color: 0xFF9E9E9E, type: 'habit'),
  Category(name: 'Saglik', icon: 'favorite', color: 0xFF4CAF50, type: 'habit'),
  Category(name: 'Calisma', icon: 'work', color: 0xFF2196F3, type: 'habit'),
  Category(name: 'Is', icon: 'business', color: 0xFFFF9800, type: 'habit'),
  Category(name: 'Ana Sayfa', icon: 'home', color: 0xFF9C27B0, type: 'habit'),
];

List<Category> defaultExpenseCategories = [
  Category(name: 'Konut', icon: 'home', color: 0xFF4CAF50, type: 'expense'),
  Category(name: 'Egitim', icon: 'school', color: 0xFF2196F3, type: 'expense'),
  Category(name: 'Gida', icon: 'restaurant', color: 0xFFFF9800, type: 'expense'),
  Category(name: 'Saglik', icon: 'favorite', color: 0xFFE91E63, type: 'expense'),
  Category(name: 'Eglence', icon: 'movie', color: 0xFF9C27B0, type: 'expense'),
  Category(name: 'Araba', icon: 'directions_car', color: 0xFF607D8B, type: 'expense'),
  Category(name: 'Diger', icon: 'more_horiz', color: 0xFF9E9E9E, type: 'expense'),
];

List<String> defaultMoodActivities = [
  'Is', 'Egzersiz', 'Aile', 'Arkadaslar', 'Saglik', 'Uyku', 'Stres',
  'Rahatlama', 'Seyahat', 'Hava durumu', 'Okul', 'Diyet', 'Iliskiler',
  'Sosyallesme', 'Verimlilik', 'Yaratıcılık', 'Bos zaman', 'Ev isleri',
  'Finans', 'Mutluluk', 'Uzuntu', 'Ofke', 'Kaygı'
];