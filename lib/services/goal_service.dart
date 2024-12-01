import '../db/database_helper.dart';

class GoalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getGoalsByUser(int userId) async {
    final db = await _dbHelper.database;
    return await db.query('goals', where: 'user_id = ?', whereArgs: [userId]);
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

  Future<int> addGoal(Map<String, dynamic> goal) async {
    final db = await _dbHelper.database;
    return await db.insert('goals', goal);
  }
}
