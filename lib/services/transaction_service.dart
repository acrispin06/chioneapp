import '../db/database_helper.dart';

class TransactionService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Obtener todas las transacciones con JOIN a categorías, íconos y tipos
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        t.id,
        t.amount,
        t.date,
        t.time,
        t.description,
        c.name AS category_name,
        i.icon_path AS icon_path,
        tt.type_name AS type_name,
        t.type_id
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      JOIN icons i ON t.icon_id = i.icon_id
      JOIN transaction_types tt ON t.type_id = tt.type_id
      ORDER BY t.date DESC
    ''');
  }

  // Insertar transacción con sincronización
  Future<int> addTransaction(Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;

    // Insertar en transactions
    int transactionId = await db.insert('transactions', transaction);

    // Insertar en incomes o expenses
    if (transaction['type_id'] == 1) {
      await db.insert('incomes', {
        'id': transactionId,
        'amount': transaction['amount'],
        'category_id': transaction['category_id'],
        'date': transaction['date'],
        'time': transaction['time'],
        'description': transaction['description'],
        'icon_id': transaction['icon_id'],
        'created_at': transaction['created_at'],
        'updated_at': transaction['updated_at'],
      });
    } else if (transaction['type_id'] == 2) {
      await db.insert('expenses', {
        'id': transactionId,
        'amount': transaction['amount'],
        'category_id': transaction['category_id'],
        'date': transaction['date'],
        'time': transaction['time'],
        'description': transaction['description'],
        'icon_id': transaction['icon_id'],
        'created_at': transaction['created_at'],
        'updated_at': transaction['updated_at'],
      });
    }

    return transactionId;
  }

  // Actualizar transacción con sincronización
  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;

    // Actualizar en transactions
    int rowsAffected = await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );

    // Actualizar en incomes o expenses
    if (transaction['type_id'] == 1) {
      await db.update('incomes', transaction, where: 'id = ?', whereArgs: [transaction['id']]);
    } else if (transaction['type_id'] == 2) {
      await db.update('expenses', transaction, where: 'id = ?', whereArgs: [transaction['id']]);
    }

    return rowsAffected;
  }

  // Eliminar transacción con sincronización
  Future<void> deleteTransaction(int id, int typeId) async {
    final db = await _dbHelper.database;

    // Eliminar de transactions
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

    // Eliminar de incomes o expenses
    if (typeId == 1) {
      await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
    } else if (typeId == 2) {
      await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    }
  }

  // Calcular el total de transacciones por tipo
  Future<double> calculateTotalByType(int typeId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type_id = ?
    ''', [typeId]);

    return result.isNotEmpty ? (result.first['total'] ?? 0.0) as double : 0.0;
  }

  //calculateGoal
  Future<Object> calculateGoal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'goal'
    ''');

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }

  //getCategoryName
  Future<Object?> getCategoryName(int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
    return result.isNotEmpty ? result.first['name'] : 'Unknown';
  }
}
