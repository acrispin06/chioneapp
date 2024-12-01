import '../db/database_helper.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Obtiene todas las categorías de la base de datos
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories');

    // Convierte cada resultado a un objeto Category
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Obtiene una categoría específica por su ID
  Future<Category?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Category.fromMap(result.first);
    }
    return null; // Si no se encuentra, devuelve null
  }

  /// Agrega una nueva categoría a la base de datos
  Future<int> addCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  /// Actualiza una categoría existente
  Future<int> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Elimina una categoría por su ID
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Obtiene todas las categorías de un tipo específico (por ejemplo, income o expense)
  Future<List<Category>> getCategoriesByType(int type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }
}
