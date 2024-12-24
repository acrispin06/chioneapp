import 'package:chioneapp/models/goal.dart';
import 'package:flutter/foundation.dart';
import '../services/goal_service.dart';

class GoalViewModel with ChangeNotifier {
  final GoalService _goalService = GoalService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Goal> _goals = []; // Cambiar tipo a List<Goal> para consistencia

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Goal> get goals => _goals;

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

  Future<void> fetchGoals() async {
    _setLoading(true);
    try {
      final goalData = await _goalService.getAllGoals(); // Devuelve una lista de Map<String, dynamic>
      final goals = goalData.map((data) => Goal.fromMap(data)).toList();
      _setGoals(goals);
      _setErrorMessage('');
    } catch (e) {
      _setErrorMessage('Error fetching goals: $e');
    } finally {
      _setLoading(false);
    }
  }

  //addGoal
  Future<void> addGoal(Goal goal) async {
    _setLoading(true);
    try {
      await _goalService.addGoal(goal.toMap());
      await fetchGoals();
      _setErrorMessage('');
    } catch (e) {
      _setErrorMessage('Error adding goal: $e');
    } finally {
      _setLoading(false);
    }
  }
}
