class Expense {
  int? id;
  double amount;
  int categoryId;
  DateTime date;
  DateTime time;
  String description;
  int? iconId;
  DateTime createdAt;
  DateTime updatedAt;

  Expense({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.time,
    required this.description,
    this.iconId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
      'description': description,
      'icon_id': iconId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      categoryId: map['category_id'],
      date: DateTime.parse(map['date']),
      time: DateTime.parse(map['time']),
      description: map['description'],
      iconId: map['icon_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
