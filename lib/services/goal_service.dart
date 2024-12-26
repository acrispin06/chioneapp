import '../db/database_helper.dart';

class GoalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await _dbHelper.database;
    return await db.query('goals');
  }

  Future<Object> calculateProgress(int goalId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(progress_percentage) as progress
      FROM goal_transactions
      WHERE goal_id = ?
    ''', [goalId]);

    return result.isNotEmpty ? result.first['progress'] ?? 0.0 : 0.0;
  }

  //adding a goal with sincronization on goal-categories table
  Future<int> addGoalWithCategory(Map<String, dynamic> goal, int categoryId) async {
    final db = await _dbHelper.database;

    // Inserta la meta en la tabla `goals`
    final goalId = await db.insert('goals', goal);

    // Inserta la relación entre la meta y la categoría en `goal_categories`
    await db.insert('goal_categories', {
      'goal_id': goalId,
      'category_id': categoryId,
    });

    return goalId;
  }

  Future<int> updateGoal(Map<String, dynamic> goal) async {
    final db = await _dbHelper.database;
    return await db.update('goals', goal, where: 'id = ?', whereArgs: [goal['id']]);
  }

  /// Actualizar el progreso de una meta
  Future<int> updateGoalProgress(int goalId, double progress) async {
    final db = await _dbHelper.database;
    return await db.rawUpdate('''
      UPDATE goals
      SET progress = ?
      WHERE id = ?
    ''', [progress, goalId]);
  }

  /// Eliminar una meta específica
  Future<int> deleteGoal(int goalId) async {
    final db = await _dbHelper.database;
    await db.delete('goal_transactions', where: 'goal_id = ?', whereArgs: [goalId]);
    return await db.delete('goals', where: 'id = ?', whereArgs: [goalId]);
  }

  /// Recalcular el progreso total de una meta basado en las transacciones
  Future<void> _recalculateProgress(int goalId) async {
    final progress = await calculateProgress(goalId) as double;
    await updateGoalProgress(goalId, progress);
  }

  /// Obtener todas las transacciones asociadas a una meta
  Future<List<Map<String, dynamic>>> getTransactionsByGoal(int goalId) async {
    final db = await _dbHelper.database;
    return await db.query('goal_transactions', where: 'goal_id = ?', whereArgs: [goalId]);
  }

  /// Obtener el monto total ahorrado para una meta
  Future<double> calculateTotalSaved(int goalId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total_saved
      FROM goal_transactions
      WHERE goal_id = ?
    ''', [goalId]);

    return result.isNotEmpty ? (result.first['total_saved'] as double? ?? 0.0) : 0.0;
  }

  /// Sincronizar todas las metas recalculando su progreso
  Future<void> syncAllGoals() async {
    final db = await _dbHelper.database;
    final goals = await getAllGoals();

    for (final goal in goals) {
      final goalId = goal['id'] as int;
      await _recalculateProgress(goalId);
    }
  }
}
