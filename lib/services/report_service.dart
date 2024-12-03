import '../db/database_helper.dart';

class ReportService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  //getAllReports
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      strftime('%m', date) AS month,
      strftime('%Y', date) AS year,
      (SELECT SUM(amount) 
         FROM incomes 
         WHERE strftime('%m', date) = strftime('%m', incomes.date) 
           AND strftime('%Y', date) = strftime('%Y', incomes.date)) AS totalIncome,
      (SELECT SUM(amount) 
         FROM expenses 
         WHERE strftime('%m', date) = strftime('%m', expenses.date) 
           AND strftime('%Y', date) = strftime('%Y', expenses.date)) AS totalExpense
    FROM transactions
    GROUP BY year, month
    ORDER BY year DESC, month DESC;
    ''');

    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>> getMonthlyReport(int month, int year) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT SUM(amount) FROM incomes WHERE strftime('%m', date) = ? AND strftime('%Y', date) = ?) as totalIncome,
        (SELECT SUM(amount) FROM expenses WHERE strftime('%m', date) = ? AND strftime('%Y', date) = ?) as totalExpense
    ''', [month.toString().padLeft(2, '0'), year, month.toString().padLeft(2, '0'), year]);

    if (result.isNotEmpty) {
      final totalIncome = (result.first['totalIncome'] as num?)?.toDouble() ?? 0.0;
      final totalExpense = (result.first['totalExpense'] as num?)?.toDouble() ?? 0.0;

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } else {
      return {'totalIncome': 0.0, 'totalExpense': 0.0, 'balance': 0.0};
    }
  }
}