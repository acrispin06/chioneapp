import '../db/database_helper.dart';
import '../models/budget.dart';

class BudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Budget>> getBudgetsByUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('budgets', where: 'user_id = ?', whereArgs: [userId]);

    // Convierte los resultados en una lista de objetos Budget
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  //calculate Total budget
  Future<double> calculateTotalBudget(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as totalBudget
      FROM budgets
      WHERE user_id = ?
    ''', [userId]);

    return (result.first['totalBudget'] as num?)?.toDouble() ?? 0.0;
  }
}
