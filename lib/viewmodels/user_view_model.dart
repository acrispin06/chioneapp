import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class UserViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> fetchUsers() async {
    _users = await _dbHelper.getUsers();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await _dbHelper.insertUser(user);
    await fetchUsers();
  }
}
