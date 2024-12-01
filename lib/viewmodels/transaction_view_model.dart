import 'package:flutter/foundation.dart';
import '../services/transaction_service.dart';

class TransactionViewModel with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _transactions = [];
  double _total = 0.0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get transactions => _transactions;
  double get total => _total;

  Future<void> fetchTransactions(String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _transactionService.getAllTransactions(type);
      _total = await _transactionService.calculateTotal(type);
    } catch (e) {
      _errorMessage = 'Error fetching transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      await fetchTransactions(transaction['type']);
    } catch (e) {
      _errorMessage = 'Error adding transaction';
    }
  }
}
