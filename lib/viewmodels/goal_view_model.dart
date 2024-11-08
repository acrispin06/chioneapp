import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/goal.dart';

class GoalViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  Future<void> fetchGoals() async {
    _goals = await _dbHelper.getGoals();
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    await _dbHelper.insertGoal(goal);
    await fetchGoals();
  }
}