import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    CREATE TABLE IF NOT EXISTS currencies (
      currency_id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      symbol TEXT NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS transaction_types (
      type_id INTEGER PRIMARY KEY,
      type_name TEXT NOT NULL UNIQUE
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      currency_id INTEGER,
      budgetGoal REAL,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (currency_id) REFERENCES currencies(currency_id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS icons (
      icon_id INTEGER PRIMARY KEY,
      icon_name TEXT NOT NULL,
      icon_path TEXT
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      type INTEGER,
      icon_id INTEGER,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (type) REFERENCES transaction_types(type_id),
      FOREIGN KEY (icon_id) REFERENCES icons(icon_id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS goal_categories (
      goal_id INTEGER,
      category_id INTEGER,
      PRIMARY KEY (goal_id, category_id),
      FOREIGN KEY (goal_id) REFERENCES goals(id),
      FOREIGN KEY (category_id) REFERENCES categories(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS incomes (
      id INTEGER PRIMARY KEY,
      amount REAL NOT NULL,
      category_id INTEGER,
      date DATE NOT NULL,
      time TIME NOT NULL,
      description TEXT,
      icon_id INTEGER,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (category_id) REFERENCES categories(id),
      FOREIGN KEY (icon_id) REFERENCES icons(icon_id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS expenses (
      id INTEGER PRIMARY KEY,
      amount REAL NOT NULL,
      category_id INTEGER,
      date DATE NOT NULL,
      time TIME NOT NULL,
      description TEXT,
      icon_id INTEGER,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES categories(id),
      FOREIGN KEY (icon_id) REFERENCES icons(icon_id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS budgets (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      category_id INTEGER,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (category_id) REFERENCES categories(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS goals (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      name TEXT NOT NULL,
      amount REAL NOT NULL,
      currentAmount REAL DEFAULT 0.0,
      targetDate TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS goal_transactions (
      id INTEGER PRIMARY KEY,
      goal_id INTEGER,
      transaction_id INTEGER,
      progress_percentage REAL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (goal_id) REFERENCES goals(id),
      FOREIGN KEY (transaction_id) REFERENCES incomes(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS user_category_preferences (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      category_id INTEGER,
      preferred_budget REAL,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (category_id) REFERENCES categories(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS audit_logs (
      id INTEGER PRIMARY KEY,
      table_name TEXT NOT NULL,
      record_id INTEGER NOT NULL,
      changed_field TEXT NOT NULL,
      old_value TEXT,
      new_value TEXT,
      change_date TEXT DEFAULT (datetime('now')),
      changed_by INTEGER,
      FOREIGN KEY (changed_by) REFERENCES users(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      date TEXT NOT NULL,
      type TEXT,
      entity_id INTEGER,
      entity_type TEXT,
      status TEXT DEFAULT 'unread',
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS notification_types (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY,
      amount REAL NOT NULL,
      category_id INTEGER,
      type_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      description TEXT,
      icon_id INTEGER,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (category_id) REFERENCES categories(id),
      FOREIGN KEY (icon_id) REFERENCES icons(icon_id),
      FOREIGN KEY (type_id) REFERENCES transaction_types(type_id)
    );
    ''');

    await db.execute('''
    CREATE VIEW IF NOT EXISTS category_spent AS
    SELECT category_id AS categoryId, SUM(amount) AS spent
    FROM transactions
    WHERE type_id = 2
    GROUP BY category_id
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS reports (
    id INTEGER PRIMARY KEY,
    period_type TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    total_income REAL DEFAULT 0.0,
    total_expense REAL DEFAULT 0.0,
    balance REAL GENERATED ALWAYS AS (total_income - total_expense) VIRTUAL,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
    );
    ''');
  }
  //Funcion para crear data de ejemplo
  Future<void> createExampleData() async{
    final db = await database;
    // Insert example transaction types and notification types
    //inserting default values
    //Currencies
    await db.insert('currencies',{'name': 'Nuevo Sol','symbol': 'S/.' } );
    //transaction types
    await db.insert('transaction_types', {'type_name': 'income'});
    await db.insert('transaction_types', {'type_name': 'expense'});
    //users
    await db.insert('users', {'name': 'Admin', 'currency_id': 1, 'budgetGoal': 0.0});
    //icons
    await db.insert('icons', {'icon_name': 'default', 'icon_path': 'assets/icons/default.png'});
    await db.insert('icons', {'icon_name': 'food', 'icon_path': 'assets/icons/food.png'});
    await db.insert('icons', {'icon_name': 'transport', 'icon_path': 'assets/icons/transport.png'});
    await db.insert('icons', {'icon_name': 'shopping', 'icon_path': 'assets/icons/shopping.png'});
    await db.insert('icons', {'icon_name': 'entertainment', 'icon_path': 'assets/icons/entertainment.png'});
    await db.insert('icons', {'icon_name': 'health', 'icon_path': 'assets/icons/health.png'});
    await db.insert('icons', {'icon_name': 'education', 'icon_path': 'assets/icons/education.png'});
    await db.insert('icons', {'icon_name': 'others', 'icon_path': 'assets/icons/others.png'});
    //categories
    await db.insert('categories', {'name': 'Food', 'type': 2, 'icon_id': 2});
    await db.insert('categories', {'name': 'Transport', 'type': 2, 'icon_id': 3});
    await db.insert('categories', {'name': 'Shopping', 'type': 2, 'icon_id': 4});
    await db.insert('categories', {'name': 'Entertainment', 'type': 2, 'icon_id': 5});
    await db.insert('categories', {'name': 'Health', 'type': 2, 'icon_id': 6});
    await db.insert('categories', {'name': 'Education', 'type': 2, 'icon_id': 7});
    await db.insert('categories', {'name': 'Others', 'type': 2, 'icon_id': 8});
    //goals-categories
    await db.insert('goal_categories', {'goal_id': 1, 'category_id': 1});
    await db.insert('goal_categories', {'goal_id': 2, 'category_id': 2});
    //budgets
    await db.insert('budgets', {'user_id': 1, 'category_id': 1, 'amount': 100.0, 'date': '2024-11-29'});
    await db.insert('budgets', {'user_id': 1, 'category_id': 2, 'amount': 50.0, 'date': '2024-11-29'});
    await db.insert('budgets', {'user_id': 1, 'category_id': 3, 'amount': 200.0, 'date': '2024-11-29'});
    await db.insert('budgets', {'user_id': 1, 'category_id': 4, 'amount': 150.0, 'date': '2024-11-29'});
    await db.insert('budgets', {'user_id': 1, 'category_id': 5, 'amount': 100.0, 'date': '2024-11-29'});
    await db.insert('budgets', {'user_id': 1, 'category_id': 6, 'amount': 50.0, 'date': '2024-11-29'});
    await db.insert('budgets', {'user_id': 1, 'category_id': 7, 'amount': 50.0, 'date': '2024-11-29'});
    //goals
    await db.insert('goals', {'user_id': 1, 'name': 'Buy a new car', 'amount': 10000.0, 'targetDate': '2022-12-31'});
    await db.insert('goals', {'user_id': 1, 'name': 'Buy a new house', 'amount': 50000.0, 'targetDate': '2025-12-31'});
    //goals_transactions
    await db.insert('goal_transactions', {'goal_id': 1, 'transaction_id': 1, 'progress_percentage': 10.0});
    await db.insert('goal_transactions', {'goal_id': 1, 'transaction_id': 2, 'progress_percentage': 20.0});
    await db.insert('goal_transactions', {'goal_id': 1, 'transaction_id': 3, 'progress_percentage': 30.0});
    //notification_types
    await db.insert('notification_types', {'name': 'alert'});
    await db.insert('notification_types', {'name': 'info'});
    await db.insert('notification_types', {'name': 'warning'});
    await db.insert('notification_types', {'name': 'error'});
    await db.insert('notification_types', {'name': 'reminder'});
    await db.insert('notification_types', {'name': 'update'});
    await db.insert('notification_types', {'name': 'transaction'});
    //notifications
    await db.insert('notifications', {'title': 'Alert 1', 'message': 'Alert message 1', 'date': '2024-11-29', 'type': 'alert', 'entity_id': 1, 'entity_type': 'transaction'});
    await db.insert('notifications', {'title': 'Alert 2', 'message': 'Alert message 2', 'date': '2024-11-29', 'type': 'alert', 'entity_id': 2, 'entity_type': 'transaction'});
    await db.insert('notifications', {'title': 'Alert 3', 'message': 'Alert message 3', 'date': '2024-11-29', 'type': 'alert', 'entity_id': 3, 'entity_type': 'transaction'});
    //reports
    await db.insert('reports', {'period_type': 'monthly', 'start_date': '2024-11-01', 'end_date': '2024-11-30', 'total_income': 1000.0, 'total_expense': 500.0, 'user_id': 1});
    await db.insert('reports', {'period_type': 'monthly', 'start_date': '2024-12-01', 'end_date': '2024-12-31', 'total_income': 2000.0, 'total_expense': 1000.0, 'user_id': 1});
    //user category preferences
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 1, 'preferred_budget': 100.0});
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 2, 'preferred_budget': 50.0});
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 3, 'preferred_budget': 200.0});
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 4, 'preferred_budget': 150.0});
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 5, 'preferred_budget': 100.0});
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 6, 'preferred_budget': 50.0});
    await db.insert('user_category_preferences', {'user_id': 1, 'category_id': 7, 'preferred_budget': 50.0});
    //transactions
    await db.insert('transactions', {'amount': 100.0, 'category_id': 1, 'type_id': 1, 'date': '2024-11-29', 'time': '12:00:00', 'description': 'Salary Income', 'icon_id': 2});
    await db.insert('transactions', {'amount': 50.0, 'category_id': 2, 'type_id': 2, 'date': '2024-11-29', 'time': '14:00:00', 'description': 'Grocery Shopping', 'icon_id': 3});
  }
  //CRUD Operations for each model
  //Crud for user
  Future<List<Map<String, dynamic>>> fetchUser() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('users', row);
  }

  Future<List<Map<String, Object?>>> getUserById(int id) async {
    final db = await database;
    return await db.query('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> updateUser(Map<String, dynamic> row) async {
    final db = await database;
    return await db.query('users', where: 'id = ?', whereArgs: [row['id']]);
  }

  //the update of a budget goal is the result of the sum of all the budgets of the user
  Future<int> updateUserBudgetGoal(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> budgets = await db.rawQuery('''
      SELECT SUM(amount) as totalBudget
      FROM budgets
      WHERE user_id = ?
    ''', [userId]);
    final double totalBudget = budgets[0]['totalBudget'];
    return await db.rawUpdate('''
      UPDATE users
      SET budgetGoal = ?
      WHERE id = ?
    ''', [totalBudget, userId]);
  }

  //insert transaction
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('transactions', row);
  }

  //get categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final db = await database;
    return await db.query('categories');
  }
}
