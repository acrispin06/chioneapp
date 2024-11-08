class Budget {
  final int id;
  final int categoryId;
  String category;
  final double amount;
  double spent;
  final DateTime date;

  Budget({
    required this.id,
    required this.categoryId,
    this.category = '',
    required this.amount,
    this.spent = 0.0,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'category': category,
      'amount': amount,
      'spent': spent,
      'date': date.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      category: map.containsKey('category') ? map['category'] : '',
      amount: map['amount'],
      spent: map['spent'] ?? 0.0,
      date: DateTime.parse(map['date']),
    );
  }
}
