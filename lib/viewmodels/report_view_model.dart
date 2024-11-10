import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/report.dart';
import '../models/transaction.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Report> _reports = [];
  List<Transaction> _transactions = [];
  String _selectedPeriod = "Daily";

  List<Report> get reports => _reports;
  String get selectedPeriod => _selectedPeriod;

  Future<void> fetchReports() async {
    await fetchTransactions();
    // _reports = await _dbHelper.getReports();
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    notifyListeners();
  }

  Future<void> addReport(Report report) async {
    await _dbHelper.insertReport(report);
    await fetchReports();
  }

  // Método para obtener las transacciones filtradas por período
  List<Transaction> getFilteredTransactions() {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return _transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(Duration(days: 1))) &&
          transaction.date.isBefore(now.add(Duration(days: 1)));
    }).toList();
  }

  // Método para obtener el balance total
  double getTotalBalance() {
    double totalIncome = getTotalIncome();
    double totalExpense = getTotalExpense();
    return totalIncome - totalExpense;
  }

  // Método para obtener el gasto total
  double getTotalExpense() {
    return getFilteredTransactions()
        .where((transaction) => transaction.type == 'expense')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Método para obtener el ingreso total
  double getTotalIncome() {
    return getFilteredTransactions()
        .where((transaction) => transaction.type == 'income')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Método para obtener los puntos de datos para el gráfico de ingresos y gastos
  List<FlSpot> getIncomeExpenseSpots() {
    List<FlSpot> spots = [];
    List<Transaction> filteredTransactions = getFilteredTransactions();
    filteredTransactions.sort((a, b) => a.date.compareTo(b.date));

    Map<DateTime, double> dateAmountMap = {};

    for (var transaction in filteredTransactions) {
      DateTime date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (!dateAmountMap.containsKey(date)) {
        dateAmountMap[date] = 0.0;
      }
      double amount = transaction.type == 'income' ? transaction.amount : -transaction.amount;
      dateAmountMap[date] = dateAmountMap[date]! + amount;
    }

    int i = 0;
    for (var date in dateAmountMap.keys) {
      spots.add(FlSpot(i.toDouble(), dateAmountMap[date]!));
      i++;
    }

    return spots;
  }

  // Cambiar el período seleccionado (Daily, Weekly, Monthly, Yearly)
  void changePeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}