import 'package:flutter/foundation.dart';
import '../services/budget_service.dart';

class BudgetViewModel with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _budgets = [];
  double _totalBudget = 0.0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get budgets => _budgets;
  double get totalBudget => _totalBudget;

  Future<void> fetchBudgets(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = (await _budgetService.getBudgetsByUser(userId)).cast<Map<String, dynamic>>();
      _totalBudget = await _budgetService.calculateTotalBudget(userId);
    } catch (e) {
      _errorMessage = 'Error fetching budgets';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
