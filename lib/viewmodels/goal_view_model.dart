import 'package:chioneapp/models/goal.dart';
import 'package:flutter/foundation.dart';
import '../services/goal_service.dart';
import '../services/transaction_service.dart';

class GoalViewModel with ChangeNotifier {
  final GoalService _goalService = GoalService();
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Goal> _goals = [];

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Goal> get goals => _goals;

  // Métodos privados para manejo de estado
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setGoals(List<Goal> goals) {
    _goals = goals;
    notifyListeners();
  }

  /// Cargar metas desde el servicio
  Future<void> fetchGoals() async {
    _setLoading(true);
    try {
      final goalData = await _goalService.getAllGoals();
      final goals = goalData.map((data) => Goal.fromMap(data)).toList();
      _setGoals(goals);
      _setErrorMessage('');
    } catch (e) {
      _setErrorMessage('Error fetching goals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar una nueva meta
  Future<void> addGoalWithCategory(Goal goal, int categoryId) async {
    _setLoading(true);
    try {
      await _goalService.addGoalWithCategory(goal.toMap(), categoryId);
      await fetchGoals(); // Refrescar la lista de metas
    } catch (e) {
      _setErrorMessage('Error adding goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar una meta
  Future<void> deleteGoal(int goalId) async {
    _setLoading(true);
    try {
      await _goalService.deleteGoal(goalId);
      await fetchGoals();
      _setErrorMessage('');
    } catch (e) {
      _setErrorMessage('Error deleting goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sincronizar transacciones con una meta
  Future<void> syncGoalProgress(int goalId) async {
    _setLoading(true);
    try {
      // Obtener todas las transacciones asociadas a la meta
      final transactions = await _transactionService.getTransactionsByGoal(goalId);

      // Calcular el total ahorrado basado en las transacciones
      final totalSaved = transactions.fold<double>(
        0.0,
            (sum, transaction) => sum + transaction['amount'],
      );

      // Actualizar el progreso en el servicio
      await _goalService.updateGoalProgress(goalId, totalSaved);
      await fetchGoals();
    } catch (e) {
      _setErrorMessage('Error syncing goal progress: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sincronización completa de todas las metas
  Future<void> syncAllGoals() async {
    _setLoading(true);
    try {
      for (final goal in _goals) {
        await syncGoalProgress(goal.id!);
      }
    } catch (e) {
      _setErrorMessage('Error syncing all goals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar una meta existente
  Future<void> updateGoal(Goal updatedGoal) async {
    _setLoading(true);
    try {
      await _goalService.updateGoal(updatedGoal.toMap());
      await fetchGoals();
      _setErrorMessage('');
    } catch (e) {
      _setErrorMessage('Error updating goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleTransactionChange(int goalId) async {
    _setLoading(true);
    try {
      await syncGoalProgress(goalId);
    } catch (e) {
      _setErrorMessage('Error syncing goal progress: $e');
    } finally {
      _setLoading(false);
    }
  }
}
