import '../db/database_helper.dart';

class ReportService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

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