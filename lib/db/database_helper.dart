import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../models/transaction.dart' as transaction_model;
import '../models/category.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/report.dart';
import '../models/AppNotification.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chioneapp.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        name TEXT,
        currency TEXT,
        budgetGoal REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY,
        type TEXT,
        amount REAL,
        category INTEGER, -- Asumimos que aquí almacenas el categoryId
        date TEXT,
        description TEXT,
        icon TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT,
        icon TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY,
        categoryId INTEGER,
        amount REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY,
        name TEXT,
        amount REAL,
        currentAmount REAL,
        targetDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY,
        period TEXT,
        totalIncome REAL,
        totalExpense REAL,
        balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY,
        title TEXT,
        message TEXT,
        date TEXT,
        type TEXT
      )
    ''');

    // Crear la vista para calcular el gasto total por categoría
    await db.execute('''
      CREATE VIEW category_spent AS
      SELECT category AS categoryId, SUM(amount) AS spent
      FROM transactions
      WHERE type = 'expense'
      GROUP BY category
    ''');
  }

  // CRUD operations for each model

  // User Operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Transaction Operations
  Future<int> insertTransaction(transaction_model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<transaction_model.Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions');
    return List.generate(maps.length, (i) => transaction_model.Transaction.fromMap(maps[i]));
  }

  Future<List<transaction_model.Transaction>> getTransactionsByCategory(int categoryId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [categoryId],
    );

    return List.generate(maps.length, (i) {
      return transaction_model.Transaction.fromMap(maps[i]);
    });
  }

  // Método para obtener el gasto total por categoría desde la vista
  Future<double> getSpentByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'category_spent',
      columns: ['spent'],
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    if (result.isNotEmpty) {
      return result.first['spent'] as double;
    } else {
      return 0.0; // Si no hay gasto para esa categoría, devuelve 0
    }
  }

  // Category Operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<String> getCategoryName(int categoryId) async {
    final db = await database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      return 'Unknown';
    }
  }

  // Budget Operations
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  // Goal Operations
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // Report Operations
  Future<int> insertReport(Report report) async {
    final db = await database;
    return await db.insert('reports', report.toMap());
  }

  Future<List<Report>> getReports() async {
    final db = await database;
    final maps = await db.query('reports');
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }

  // Notification Operations
  Future<int> insertNotification(AppNotification notification) async {
    final db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<AppNotification>> getNotifications() async {
    final db = await database;
    final maps = await db.query('notifications');
    return List.generate(maps.length, (i) => AppNotification.fromMap(maps[i]));
  }
}
