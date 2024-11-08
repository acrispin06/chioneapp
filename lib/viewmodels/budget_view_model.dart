import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/budget.dart';

class BudgetViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Budget> _budgets = [];

  List<Budget> get budgets => _budgets;

  Future<void> fetchBudgets() async {
    _budgets = await _dbHelper.getBudgets();
    for (var budget in _budgets) {
      budget.category = await _dbHelper.getCategoryName(budget.categoryId);
      budget.spent = await _dbHelper.getSpentByCategory(budget.categoryId);
    }
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _dbHelper.insertBudget(budget);
    await fetchBudgets();
  }

}