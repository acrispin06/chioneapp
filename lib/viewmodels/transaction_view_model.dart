import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaction.dart';

class TransactionViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Transaction> _transactions = [];
  Map<int, String> _categoryNames = {};

  List<Transaction> get transactions => _transactions;

  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  double _totalIncome = 0.0;
  double _goal = 20000.0;

  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  double get totalIncome => _totalIncome;
  double get goal => _goal;

  Future<void> fetchTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    _totalBalance = _calculateTotalBalance();
    _totalExpense = _calculateTotalExpense();
    _totalIncome = _calculateTotalIncome();

    for (var transaction in _transactions) {
      if (!_categoryNames.containsKey(transaction.category)) {
        String categoryName = await _dbHelper.getCategoryName(transaction.category);
        _categoryNames[transaction.category] = categoryName;
      }
    }

    notifyListeners();
  }

  double _calculateTotalBalance() {
    return _transactions.fold(0.0, (sum, transaction) =>
    transaction.type == 'income' ? sum + transaction.amount : sum - transaction.amount);
  }

  double _calculateTotalExpense() {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await fetchTransactions();
  }

  double getTotalExpense() {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double _calculateTotalIncome() {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double getWeeklyIncome() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));
    return _transactions
        .where((transaction) =>
    transaction.type == 'income' &&
        transaction.date.isAfter(weekAgo) &&
        transaction.date.isBefore(now))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double getWeeklyFoodExpense() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));
    return _transactions
        .where((transaction) =>
    transaction.type == 'expense' &&
        transaction.category == 1 &&
        transaction.date.isAfter(weekAgo) &&
        transaction.date.isBefore(now))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<Transaction> getTransactionsByMonth(String month) {
    return _transactions.where((transaction) {
      final transactionMonth = _getMonthName(transaction.date.month);
      return transactionMonth == month;
    }).toList();
  }

  String getCategoryName(int categoryId) {
    return _categoryNames[categoryId] ?? 'Unknown';
  }

  List<Transaction> getFilteredTransactions(String period) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month);
        break;
      default:
        startDate = DateTime(now.year);
        break;
    }

    return _transactions.where((transaction) {
      return transaction.date.isAfter(startDate) && transaction.date.isBefore(now);
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}
