import '../db/database_helper.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _dbHelper.fetchUser();
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    return await _dbHelper.insertUser(user);
  }

  Future<void> updateUserBudgetGoal(int userId) async {
    await _dbHelper.updateUserBudgetGoal(userId);
  }
}
