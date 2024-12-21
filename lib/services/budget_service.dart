import '../db/database_helper.dart';
import '../models/budget.dart';

class BudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Obtener todos los presupuestos asociados a un usuario
  Future<List<Budget>> getBudgetsByUser(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((map) => Budget.fromMap(map)).toList();
  }

  /// Crear un nuevo presupuesto
  Future<int> createBudget(Budget budget) async {
    final db = await _dbHelper.database;

    // Validar unicidad de categoría para el usuario
    final existing = await db.query(
      'budgets',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [budget.userId, budget.categoryId],
    );
    if (existing.isNotEmpty) {
      throw Exception("Budget already exists for this category.");
    }

    return await db.insert('budgets', budget.toMap());
  }

  /// Actualizar un presupuesto existente
  Future<int> updateBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Eliminar un presupuesto por ID
  Future<int> deleteBudget(int budgetId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  /// Obtener el total del presupuesto de un usuario
  Future<double> calculateTotalBudget(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as totalBudget
      FROM budgets
      WHERE user_id = ?
    ''', [userId]);

    return (result.first['totalBudget'] as num?)?.toDouble() ?? 0.0;
  }

  /// Obtener el gasto total de un usuario
  Future<double> calculateTotalSpent(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(spent) as totalSpent
      FROM budgets
      WHERE user_id = ?
    ''', [userId]);

    return (result.first['totalSpent'] as num?)?.toDouble() ?? 0.0;
  }

  /// Actualizar el campo `spent` de un presupuesto
  Future<int> updateSpentAmount(int budgetId, double amountSpent) async {
    final db = await _dbHelper.database;

    // Obtener el presupuesto actual
    final budget = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [budgetId],
    );

    if (budget.isEmpty) {
      throw Exception("Budget not found.");
    }

    final currentSpent = (budget.first['spent'] as num).toDouble();
    final updatedSpent = currentSpent + amountSpent;

    // Validar que el gasto no exceda el presupuesto total
    final budgetAmount = (budget.first['amount'] as num).toDouble();
    if (updatedSpent > budgetAmount) {
      throw Exception("Exceeded budget limit.");
    }

    // Actualizar el gasto
    return await db.update(
      'budgets',
      {'spent': updatedSpent},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  /// Calcular el progreso del gasto dentro de un presupuesto
  Future<double> calculateBudgetProgress(int budgetId) async {
    final db = await _dbHelper.database;

    // Obtener el presupuesto actual
    final budget = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [budgetId],
    );

    if (budget.isEmpty) {
      throw Exception("Budget not found.");
    }

    final spent = (budget.first['spent'] as num).toDouble();
    final totalAmount = (budget.first['amount'] as num).toDouble();

    // Calcular el progreso como un porcentaje
    return (spent / totalAmount).clamp(0, 1);
  }

  /// Obtener los presupuestos con progreso detallado (usado en las vistas)
  Future<List<Map<String, dynamic>>> getBudgetsWithProgress(int userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        budgets.id,
        budgets.category_id,
        budgets.amount,
        budgets.spent,
        (budgets.amount - budgets.spent) as remainingAmount,
        categories.name as categoryName
      FROM budgets
      INNER JOIN categories ON budgets.category_id = categories.id
      WHERE budgets.user_id = ?
    ''', [userId]);

    return result;
  }

  Future<String> getCategoryName(int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
    return result.isNotEmpty ? result.first['name'] as String : 'Unknown';
  }
}