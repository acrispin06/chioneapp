import 'package:chioneapp/models/transaction_type.dart';

class Transaction {
  int? id;
  double amount;
  int categoryId;
  String description;
  int? iconId;
  DateTime date;
  DateTime time;
  DateTime createdAt;
  DateTime updatedAt;
  TransactionType type;

  Transaction({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.description,
    this.iconId,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'description': description,
      'icon_id': iconId,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type.typeId, // Almacena el ID del tipo de transacción (1 para ingreso, 2 para gasto)
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'],
      description: map['description'],
      iconId: map['icon_id'],
      date: DateTime.parse(map['date']),
      time: DateTime.parse(map['time']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      type: TransactionType.fromMap({
        'type_id': map['type_id'],
        'type_name': map['type_id'] == 1 ? 'income' : 'expense',
      }),
    );
  }
}
