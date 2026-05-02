class QuickAction {
  final String id;
  final String name;
  final String icon;
  bool isEnabled;
  int order;

  QuickAction({
    required this.id,
    required this.name,
    required this.icon,
    required this.isEnabled,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isEnabled': isEnabled ? 1 : 0,
      'order': order,
    };
  }

  factory QuickAction.fromMap(Map<String, dynamic> map) {
    return QuickAction(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      isEnabled: map['isEnabled'] == 1,
      order: map['order'],
    );
  }
}

List<QuickAction> defaultQuickActions = [
  QuickAction(id: 'habits', name: 'Alışkanlıklar ve Görevler', icon: 'check_circle', isEnabled: true, order: 0),
  QuickAction(id: 'moods', name: 'Duygular', icon: 'mood', isEnabled: false, order: 1),
  QuickAction(id: 'expenses', name: 'Harcamalar', icon: 'attach_money', isEnabled: false, order: 2),
  QuickAction(id: 'journal', name: 'Gunluk', icon: 'edit_note', isEnabled: false, order: 3),
  QuickAction(id: 'focus', name: 'Odaklanma', icon: 'timer', isEnabled: false, order: 4),
];