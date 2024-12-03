import 'package:flutter/foundation.dart';
import '../services/transaction_service.dart';

class TransactionViewModel with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _transactions = [];
  double _total = 0.0;
  double _goal = 0.0;
  double _totalIncome = 0.0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get transactions => _transactions;
  double get total => _total;
  double get goal => _goal;
  double get totalIncome => _totalIncome;

  Future<void> fetchTransactions(String type) async {
    _setLoadingState(true);
    try {
      _transactions = await _transactionService.getAllTransactions(type);
      _total = await _transactionService.calculateTotal(type) as double;
    } catch (e) {
      _setErrorMessage('Error fetching transactions: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      await fetchTransactions(transaction['type']);
    } catch (e) {
      _setErrorMessage('Error adding transaction: $e');
    }
  }

  Future<void> totalBalance() async {
    _setLoadingState(true);
    try {
      _total = await _transactionService.calculateTotalBalance() as double;
    } catch (e) {
      _setErrorMessage('Error fetching total balance: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> totalExpense() async {
    _setLoadingState(true);
    try {
      _total = await _transactionService.calculateTotalExpense() as double;
    } catch (e) {
      _setErrorMessage('Error fetching total expense: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> weeklyIncome() async {
    _setLoadingState(true);
    try {
      _totalIncome = await _transactionService.calculateTotalWeeklyIncome() as double;
    } catch (e) {
      _setErrorMessage('Error fetching weekly income: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> weeklyFoodExpense() async {
    _setLoadingState(true);
    try {
      _total = await _transactionService.calculateTotalWeeklyFoodExpense() as double;
    } catch (e) {
      _setErrorMessage('Error fetching weekly food expense: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> filteredTransactions(String type, String category, String date) async {
    _setLoadingState(true);
    try {
      _transactions = await _transactionService.getFilteredTransactions(type, category, date);
    } catch (e) {
      _setErrorMessage('Error fetching filtered transactions: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> fetchGoal() async {
    _setLoadingState(true);
    try {
      _goal = await _transactionService.calculateGoal() as double;
    } catch (e) {
      _setErrorMessage('Error fetching goal: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> fetchTotalIncome() async {
    _setLoadingState(true);
    try {
      _totalIncome = await _transactionService.calculateTotalIncome() as double;
    } catch (e) {
      _setErrorMessage('Error fetching total income: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<Object?> getCategoryName(int id) async {
    try {
      return await _transactionService.getCategoryName(id);
    } catch (e) {
      _setErrorMessage('Error fetching category name: $e');
      return null;
    }
  }

  void _setLoadingState(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}