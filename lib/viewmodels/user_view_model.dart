import 'package:flutter/foundation.dart';
import '../services/user_service.dart';

class UserViewModel with ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _users = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      _errorMessage = 'Error fetching users';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    try {
      await _userService.createUser(user);
      await fetchUsers();
    } catch (e) {
      _errorMessage = 'Error adding user';
    }
  }
}
