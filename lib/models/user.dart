class User {
  final int id;
  final String name;
  final String currency;
  final double budgetGoal;

  User({
    required this.id,
    required this.name,
    required this.currency,
    required this.budgetGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'budgetGoal': budgetGoal,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      currency: map['currency'],
      budgetGoal: map['budgetGoal'],
    );
  }
}
