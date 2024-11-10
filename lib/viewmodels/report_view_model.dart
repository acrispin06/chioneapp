import 'package:chioneapp/models/transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/report.dart';

class ReportViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Report> _reports = [];
  List<Transaction> _transactions = [];
  String _selectedPeriod = "Daily";

  List<Report> get reports => _reports;
  String get selectedPeriod => _selectedPeriod;

  Future<void> fetchReports() async {
    _reports = await _dbHelper.getReports();
    notifyListeners();
  }

  Future<void> addReport(Report report) async {
    await _dbHelper.insertReport(report);
    await fetchReports();
  }

  // Método para obtener el balance total
  double getTotalBalance() {
    double totalIncome = getTotalIncome();
    double totalExpense = getTotalExpense();
    return totalIncome - totalExpense;
  }

  // Método para obtener el gasto total
  double getTotalExpense() {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Método para obtener el ingreso total
  double getTotalIncome() {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Método para obtener los puntos de datos para el gráfico de ingresos y gastos
  List<FlSpot> getIncomeExpenseSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      double amount = transaction.type == 'income' ? transaction.amount : -transaction.amount;
      spots.add(FlSpot(i.toDouble(), amount));
    }
    return spots;
  }

  // Cambiar el período seleccionado (Daily, Weekly, Monthly, Yearly)
  void changePeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}