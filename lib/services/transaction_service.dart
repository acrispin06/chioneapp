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

  //funciones nuevas
  //Calculate Total Balance;
  Future<Object> calculateTotalBalance() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
    ''');

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }
  //Calculate Total Expense;
  Future<Object> calculateTotalExpense() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'expense'
    ''');

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }
  //Calculate Total weekly Income;
  Future<Object> calculateTotalWeeklyIncome() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'income'
      AND created_at >= date('now', '-7 days')
    ''');

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }

  //Calculate weekly Food Expense;
  Future<Object> calculateTotalWeeklyFoodExpense() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'expense'
      AND category_id = 1
      AND created_at >= date('now', '-7 days')
    ''');

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }

  //filteredTransactions
  Future<List<Map<String, dynamic>>> getFilteredTransactions(String type, String category, String date) async {
    final db = await _dbHelper.database;
    return await db.query('transactions', where: 'type = ? AND category_id = ? AND date = ?', whereArgs: [type, category, date]);
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

  //calculateTotalIncome
  Future<Object> calculateTotalIncome() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'income'
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
