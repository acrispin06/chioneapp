class Budget {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final double spent;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    double? spent,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'spent': spent,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
