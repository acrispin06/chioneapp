class Transaction {
  final int id;
  final String type; // "income" or "expense"
  double amount;
  final String category;
  final DateTime date;
  final String description;
  final String icon;

  Transaction({
    required this.id,
    required this.type,
    this.amount = 0.0,
    required this.category,
    required this.date,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'icon': icon,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      icon: map['icon'],
    );
  }
}
