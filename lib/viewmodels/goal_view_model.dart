import 'package:flutter/foundation.dart';
import '../services/goal_service.dart';

class GoalViewModel with ChangeNotifier {
  final GoalService _goalService = GoalService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _goals = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get goals => _goals;

  Future<void> fetchGoals(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _goalService.getGoalsByUser(userId);
    } catch (e) {
      _errorMessage = 'Error fetching goals';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
