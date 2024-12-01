class User {
  int? id;
  String name;
  int? currencyId;
  double budgetGoal;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    this.id,
    required this.name,
    this.currencyId,
    required this.budgetGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency_id': currencyId,
      'budgetGoal': budgetGoal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      currencyId: map['currency_id'],
      budgetGoal: map['budgetGoal'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
