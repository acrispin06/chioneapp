import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetViewModel with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  /// Estado interno
  bool _isLoading = false;
  String _errorMessage = '';
  List<Budget> _budgets = [];
  double _totalBudget = 0.0;
  double _totalSpent = 0.0;

  /// Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Budget> get budgets => _budgets;
  double get totalBudget => _totalBudget;
  double get totalSpent => _totalSpent;

  /// Cargar presupuestos de un usuario
  Future<void> fetchBudgets(int userId) async {
    _setLoading(true);

    try {
      _budgets = await _budgetService.getBudgetsByUser(userId);
      _totalBudget = await _budgetService.calculateTotalBudget(userId);
      _totalSpent = await _budgetService.calculateTotalSpent(userId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching budgets: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Crear un nuevo presupuesto
  Future<void> addBudget(int userId, int categoryId, double amount) async {
    _setLoading(true);

    try {
      final newBudget = Budget(
        userId: userId,
        categoryId: categoryId,
        amount: amount,
        spent: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        date: DateTime.now(),
      );

      await _budgetService.createBudget(newBudget);
      await fetchBudgets(userId); // Refrescar la lista después de agregar
    } catch (e) {
      _errorMessage = 'Error adding budget: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar un presupuesto existente
  Future<void> updateBudget(Budget budget) async {
    _setLoading(true);

    try {
      await _budgetService.updateBudget(budget);
      await fetchBudgets(budget.userId); // Refrescar la lista después de actualizar
    } catch (e) {
      _errorMessage = 'Error updating budget: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar un presupuesto
  Future<void> deleteBudget(int budgetId, int userId) async {
    _setLoading(true);

    try {
      await _budgetService.deleteBudget(budgetId);
      await fetchBudgets(userId); // Refrescar la lista después de eliminar
    } catch (e) {
      _errorMessage = 'Error deleting budget: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener el progreso de un presupuesto
  Future<double> getBudgetProgress(int budgetId) async {
    try {
      return await _budgetService.calculateBudgetProgress(budgetId);
    } catch (e) {
      _errorMessage = 'Error fetching budget progress: ${e.toString()}';
      return 0.0;
    }
  }

  /// Obtener la lista de presupuestos con detalles de progreso
  Future<List<Map<String, dynamic>>> getBudgetsWithProgress(int userId) async {
    try {
      return await _budgetService.getBudgetsWithProgress(userId);
    } catch (e) {
      _errorMessage = 'Error fetching budget details: ${e.toString()}';
      return [];
    }
  }

  /// Actualizar el monto gastado en un presupuesto
  Future<void> updateSpentAmount(int budgetId, double amountSpent, int userId) async {
    _setLoading(true);

    try {
      await _budgetService.updateSpentAmount(budgetId, amountSpent);
      await fetchBudgets(userId); // Refrescar la lista después de actualizar el gasto
    } catch (e) {
      _errorMessage = 'Error updating spent amount: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  //getTotalBudgetAmount
  Future<double> getTotalBudgetAmount(int userId) async {
    try {
      return await _budgetService.calculateTotalBudget(userId);
    } catch (e) {
      _errorMessage = 'Error fetching total budget amount: ${e.toString()}';
      return 0.0;
    }
  }

  //getTotalSpentAmount
  Future<double> getTotalSpentAmount(int userId) async {
    try {
      return await _budgetService.calculateTotalSpent(userId);
    } catch (e) {
      _errorMessage = 'Error fetching total spent amount: ${e.toString()}';
      return 0.0;
    }
  }

  Future<String> getCategoryName(int categoryId) async {
    try {
      return await _budgetService.getCategoryName(categoryId);
    } catch (e) {
      _setErrorMessage('Error fetching category name: $e');
      return 'Unknown';
    }
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Manejo del estado de carga
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
