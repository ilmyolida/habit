class Expense {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final bool isIncome;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      isIncome: map['isIncome'] == 1,
    );
  }
}