class Goal {
  int? id;
  int userId;
  String name;
  double amount;
  double currentAmount;
  DateTime targetDate;
  DateTime createdAt;
  DateTime updatedAt;

  Goal({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      amount: map['amount'],
      currentAmount: map['currentAmount'],
      targetDate: DateTime.parse(map['targetDate']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
