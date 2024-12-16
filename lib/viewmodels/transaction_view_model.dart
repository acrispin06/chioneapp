import 'package:flutter/foundation.dart';
import '../services/transaction_service.dart';

class TransactionViewModel with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  Future<void> fetchAllTransactions() async {
    _setLoadingState(true);
    try {
      _transactions = await _transactionService.getAllTransactions();
      await _calculateTotals();
    } catch (e) {
      _setErrorMessage('Error fetching transactions: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await _transactionService.addTransaction(transaction);
    await fetchAllTransactions();
  }

  Future<void> updateTransaction(Map<String, dynamic> transaction) async {
    await _transactionService.updateTransaction(transaction);
    await fetchAllTransactions();
  }

  Future<void> deleteTransaction(int id, int typeId) async {
    await _transactionService.deleteTransaction(id, typeId);
    await fetchAllTransactions();
  }

  Future<void> _calculateTotals() async {
    _totalIncome = await _transactionService.calculateTotalByType(1); // Ingresos
    _totalExpense = await _transactionService.calculateTotalByType(2); // Gastos
    notifyListeners();
  }

  void _setLoadingState(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  //getCategoryName
  Future<Object?> getCategoryName(int categoryId) async {
    return await _transactionService.getCategoryName(categoryId);
  }
}