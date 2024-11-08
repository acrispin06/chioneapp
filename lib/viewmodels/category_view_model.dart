import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/category.dart';

class CategoryViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    _categories = await _dbHelper.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _dbHelper.insertCategory(category);
    await fetchCategories();
  }
}
