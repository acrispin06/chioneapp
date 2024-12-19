import '../db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TransactionService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Obtener todas las transacciones con JOIN a categorías, íconos y tipos
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
    SELECT 
      t.id,
      t.amount,
      t.date,
      t.time,
      t.description,
      t.category_id,
      c.name AS category_name,
      COALESCE(i.icon_path, 'assets/icons/default.png') AS icon_path,
      tt.type_name AS type_name,
      COALESCE(t.icon_id, 1) AS icon_id,
      t.type_id
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    JOIN icons i ON t.icon_id = i.icon_id
    JOIN transaction_types tt ON t.type_id = tt.type_id
    ORDER BY t.date DESC
  ''');
  }

  Future<Map<String, dynamic>?> getTransactionById(int transactionId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      t.id,
      t.amount,
      t.date,
      t.time,
      t.description,
      t.category_id,
      c.name AS category_name,
      COALESCE(i.icon_path, 'assets/icons/default.png') AS icon_path,
      tt.type_name AS type_name,
      COALESCE(t.icon_id, 1) AS icon_id,
      t.type_id
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    LEFT JOIN icons i ON t.icon_id = i.icon_id
    JOIN transaction_types tt ON t.type_id = tt.type_id
    WHERE t.id = ?
  ''', [transactionId]);

    return result.isNotEmpty ? result.first : null;
  }

  // Insertar transacción con sincronización
  Future<int> addTransaction(Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;

    // Insertar en transactions
    int transactionId = await db.insert('transactions', transaction);

    // Insertar en incomes o expenses
    if (transaction['type_id'] == 1) {
      await db.insert('incomes', {
        'id': transactionId,
        'amount': transaction['amount'],
        'category_id': transaction['category_id'],
        'date': transaction['date'],
        'time': transaction['time'],
        'description': transaction['description'],
        'icon_id': transaction['icon_id'],
        'created_at': transaction['created_at'],
        'updated_at': transaction['updated_at'],
      });
    } else if (transaction['type_id'] == 2) {
      await db.insert('expenses', {
        'id': transactionId,
        'amount': transaction['amount'],
        'category_id': transaction['category_id'],
        'date': transaction['date'],
        'time': transaction['time'],
        'description': transaction['description'],
        'icon_id': transaction['icon_id'],
        'created_at': transaction['created_at'],
        'updated_at': transaction['updated_at'],
      });
    }

    return transactionId;
  }

  // Actualizar transacción con sincronización
  Future<void> updateTransaction(Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;

    // Preparar los datos para 'transactions' (tabla principal)
    final transactionData = {
      'amount': transaction['amount'],
      'description': transaction['description'],
      'category_id': transaction['category_id'],
      'icon_id': transaction['icon_id'],
      'date': transaction['date'],
      'time': transaction['time'],
      'updated_at': transaction['updated_at'],
      'type_id': transaction['type_id'],
    };

    // Actualizar el registro principal en la tabla 'transactions'
    await db.update(
      'transactions',
      transactionData,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );

    // Eliminar de la tabla secundaria antigua
    if (transaction['previous_type_id'] == 1) {
      await db.delete('incomes', where: 'id = ?', whereArgs: [transaction['id']]);
    } else if (transaction['previous_type_id'] == 2) {
      await db.delete('expenses', where: 'id = ?', whereArgs: [transaction['id']]);
    }

    // Insertar o actualizar en la nueva tabla secundaria según el tipo actual
    final subTableData = {
      'id': transaction['id'],
      'amount': transaction['amount'],
      'description': transaction['description'],
      'category_id': transaction['category_id'],
      'date': transaction['date'],
      'time': transaction['time'],
      'updated_at': transaction['updated_at'],
    };

    if (transaction['type_id'] == 1) {
      // Insertar en 'incomes'
      await db.insert(
        'incomes',
        subTableData,
        conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
      );
    } else if (transaction['type_id'] == 2) {
      // Insertar en 'expenses'
      await db.insert(
        'expenses',
        subTableData,
        conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
      );
    }
  }



  // Eliminar transacción con sincronización
  Future<void> deleteTransaction(int id, int typeId) async {
    final db = await _dbHelper.database;

    // Eliminar de transactions
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

    // Eliminar de incomes o expenses
    if (typeId == 1) {
      await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
    } else if (typeId == 2) {
      await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    }
  }

  // Calcular el total de transacciones por tipo
  Future<double> calculateTotalByType(int typeId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT SUM(amount) as total 
    FROM transactions 
    WHERE type_id = ?
  ''', [typeId]);

    // Convertir explícitamente a double
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }



  //calculateGoal
  Future<Object> calculateGoal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'goal'
    ''');

    return result.isNotEmpty ? result.first['total'] ?? 0.0 : 0.0;
  }

  //getCategoriesByType
  Future<List<Map<String, dynamic>>> getCategoriesByType(int typeId) async {
    final db = await _dbHelper.database;
    return await db.query('categories', where: 'type_id = ?', whereArgs: [typeId]);
  }

  //getIcons
  Future<Map<int, String>> getIcons() async {
    final db = await _dbHelper.database;
    final icons = await db.query('icons');
    return {
      for (var icon in icons) icon['icon_id'] as int: icon['icon_path'] as String,
    };
  }

  //getCategoryName
  Future<Object?> getCategoryName(int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
    return result.isNotEmpty ? result.first['name'] : 'Unknown';
  }


}
