import 'package:flutter/foundation.dart';
import '../services/transaction_service.dart';
import 'goal_view_model.dart';

class TransactionViewModel with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<Map<String, dynamic>> _categories = [];
  Map<int, String> _icons = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  List<Map<String, dynamic>> get categories => _categories;
  Map<int, String> get icons => _icons;

  Future<void> fetchAllTransactions() async {
    _setLoadingState(true);
    try {
      _transactions = await _transactionService.getAllTransactions();
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Error fetching transactions: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> fetchCategoriesByType(int typeId) async {
    _setLoadingState(true);
    try {
      _categories = await _transactionService.getCategoriesByType(typeId);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load categories: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> fetchIcons() async {
    _setLoadingState(true);
    try {
      _icons = await _transactionService.getIcons();
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load icons: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<Map<String, dynamic>?> fetchTransactionById(int transactionId) async {
    _setLoadingState(true);
    try {
      final transaction = await _transactionService.getTransactionById(transactionId);
      return transaction;
    } catch (e) {
      _setErrorMessage('Failed to fetch transaction: $e');
      return null;
    } finally {
      _setLoadingState(false);
    }
  }

  //fetchGoalTransactions
  Future<void> fetchGoalTransactions(int goalId) async {
    _setLoadingState(true);
    try {
      _transactions = await _transactionService.getGoalTransactions(goalId);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Error fetching goal transactions: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> addTransactionWithGoal(Map<String, dynamic> transaction, GoalViewModel goalViewModel, {int? goalId}) async {
    _setLoadingState(true);
    try {
      await _transactionService.addTransactionWithGoal(transaction, goalId);

      // Update transactions and goals
      await fetchAllTransactions();
      await fetchSummaryData();

      if (goalId != null) {
        await fetchGoalTransactions(goalId);
        goalViewModel.handleTransactionChange(goalId);
      }
    } catch (e) {
      _setErrorMessage('Error adding transaction: $e');
    } finally {
      _setLoadingState(false);
    }
  }


  Future<void> updateTransaction(Map<String, dynamic> transaction) async {
    _setLoadingState(true);

    try {
      // Obtener el tipo anterior
      final previousTransaction = _transactions.firstWhere((t) => t['id'] == transaction['id']);
      transaction['previous_type_id'] = previousTransaction['type_id'];

      await _transactionService.updateTransaction(transaction);

      // Refrescar los datos después de la actualización
      await fetchAllTransactions();
      await fetchSummaryData();
      if (transaction['goal_id'] != null) {
        await fetchGoalTransactions(transaction['goal_id']);
      }
      await GoalViewModel().syncGoalProgress(transaction['goal_id']);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Error updating transaction: $e');
    } finally {
      _setLoadingState(false);
    }
  }



  Future<void> deleteTransaction(int id, int typeId) async {
    await _transactionService.deleteTransaction(id, typeId);
    await fetchAllTransactions();
    await fetchSummaryData();
    await GoalViewModel().syncGoalProgress(0);
    notifyListeners();
  }

  Future<void> fetchSummaryData() async {
    _setLoadingState(true);
    try {
      _totalIncome = await _transactionService.calculateTotalByType(1);
      _totalExpense = await _transactionService.calculateTotalByType(2);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load summary data: $e');
    } finally {
      _setLoadingState(false);
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

  Future<String> getCategoryName(int categoryId) async {
    final categoryName = await _transactionService.getCategoryName(categoryId);
    return categoryName as String;
  }

  Future<List<Object>> getAvailableCategories() async {
    try {
      // Llama al servicio y retorna la lista de categorías.
      final categories = await _transactionService.getAvailableCategories();
      return categories;
    } catch (e) {
      _setErrorMessage('Failed to load available categories: $e');
      return [];
    }
  }
}