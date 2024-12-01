import '../db/database_helper.dart';

class TransactionService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getAllTransactions(String type) async {
    final db = await _dbHelper.database;
    return await db.query('transactions', where: 'type = ?', whereArgs: [type]);
  }

  Future<Object> calculateTotal(String type) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = ?
    ''', [type]);

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }

  Future<int> addTransaction(Map<String, dynamic> transaction) async {
    return await _dbHelper.insertTransaction(transaction);
  }
}
