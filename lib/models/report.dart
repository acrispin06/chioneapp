class Report {
  final int id;
  final String period; // "daily", "weekly", "monthly", "yearly"
  final double totalIncome;
  final double totalExpense;
  final double balance;

  Report({
    required this.id,
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'period': period,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      period: map['period'],
      totalIncome: map['totalIncome'],
      totalExpense: map['totalExpense'],
      balance: map['balance'],
    );
  }
}
