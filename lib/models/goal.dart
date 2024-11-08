class Goal {
  final int id;
  final String name;
  final double amount;
  final double currentAmount;
  final DateTime targetDate;

  Goal({
    required this.id,
    required this.name,
    required this.amount,
    required this.currentAmount,
    required this.targetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      currentAmount: map['currentAmount'],
      targetDate: DateTime.parse(map['targetDate']),
    );
  }
}
