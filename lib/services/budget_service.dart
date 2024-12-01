import '../db/database_helper.dart';
import '../models/budget.dart';

class BudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Budget>> getBudgetsByUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('budgets', where: 'user_id = ?', whereArgs: [userId]);

    // Mapea los resultados a una lista de objetos Budget
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  Future<double> calculateTotalBudget(int userId) async {
    // Obtén la lista de presupuestos del usuario
    final budgets = await getBudgetsByUser(userId);

    // Realiza la suma a  segurando que todos los valores sean
    // tratados como double
    double total = 0.0;
    for (var budget in budgets) {
      total += budget.amount;
    }

    return total;
  }
}