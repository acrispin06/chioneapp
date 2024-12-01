import 'package:flutter/material.dart';
import 'package:chioneapp/services/categories_service.dart';
import '../models/category.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;

  /// Método para obtener todas las categorías
  Future<void> fetchCategories() async {
    _setLoading(true);
    _categories = await _categoryService.getAllCategories();
    notifyListeners();
    _setLoading(false);
  }

  /// Método para obtener categorías de ingresos
  Future<void> fetchIncomeCategories() async {
    _setLoading(true);
    _incomeCategories = await _categoryService.getCategoriesByType(1); // 1: income
    notifyListeners();
    _setLoading(false);
  }

  /// Método para obtener categorías de gastos
  Future<void> fetchExpenseCategories() async {
    _setLoading(true);
    _expenseCategories = await _categoryService.getCategoriesByType(2); // 2: expense
    notifyListeners();
    _setLoading(false);
  }

  /// Método para agregar una nueva categoría
  Future<void> addCategory(Category category) async {
    _setLoading(true);
    await _categoryService.addCategory(category);
    await fetchCategories(); // Refresca la lista después de agregar
    notifyListeners();
    _setLoading(false);
  }

  /// Método para actualizar una categoría existente
  Future<void> updateCategory(Category category) async {
    _setLoading(true);
    await _categoryService.updateCategory(category);
    await fetchCategories(); // Refresca la lista después de actualizar
    notifyListeners();
    _setLoading(false);
  }

  /// Método para eliminar una categoría
  Future<void> deleteCategory(int categoryId) async {
    _setLoading(true);
    await _categoryService.deleteCategory(categoryId);
    await fetchCategories(); // Refresca la lista después de eliminar
    notifyListeners();
    _setLoading(false);
  }

  /// Método privado para manejar el estado de carga
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
