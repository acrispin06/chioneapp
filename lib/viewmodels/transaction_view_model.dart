import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaction.dart';

class TransactionViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> fetchTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    notifyListeners();
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

  List<Transaction> getTransactionsByMonth(String month) {
    return _transactions.where((transaction) {
      final transactionMonth = _getMonthName(transaction.date.month);
      return transactionMonth == month;
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
