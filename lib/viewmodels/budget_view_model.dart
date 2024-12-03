import 'package:flutter/foundation.dart';
import '../services/budget_service.dart';
import '../models/budget.dart';

class BudgetViewModel with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Budget> _budgets = [];
  double _totalBudget = 0.0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Budget> get budgets => _budgets;
  double get totalBudget => _totalBudget;

  Future<void> fetchBudgets(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _budgetService.getBudgetsByUser(userId);
      _totalBudget = await _budgetService.calculateTotalBudget(userId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching budgets: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
