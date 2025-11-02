import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager_hilagro/features/tasks/domain/entities/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'task_manager.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        done INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        due_date INTEGER,
        user_id TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_tasks_user_id ON tasks(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_tasks_done ON tasks(done)
    ''');

    await db.execute('''
      CREATE INDEX idx_tasks_due_date ON tasks(due_date)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN due_date INTEGER');
      await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
    }
  }

  // CRUD

  Future<int> insertTask(Task task) async {
    final db = await database;
    try {
      await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Task>> getTasksForToday(String userId) async {
    final db = await database;
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND due_date >= ? AND due_date <= ?',
        whereArgs: [userId, startOfDay, endOfDay],
        orderBy: 'due_date ASC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Task>> getTasksForWeek(String userId) async {
    final db = await database;
    try {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1).millisecondsSinceEpoch;
      final endOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 7, 23, 59, 59).millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND due_date >= ? AND due_date <= ?',
        whereArgs: [userId, startOfWeek, endOfWeek],
        orderBy: 'due_date ASC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Task>> getPendingTasksByUserId(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND done = 0',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Task>> getCompletedTasksByUserId(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND done = 1',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    try {
      final result = await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      return result;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteTask(String taskId) async {
    final db = await database;
    try {
      final result = await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
      return result;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAllTasksByUserId(String userId) async {
    final db = await database;
    try {
      final result = await db.delete(
        'tasks',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTaskCountByUserId(String userId) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE user_id = ?',
        [userId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, int>> getTaskStatsByUserId(String userId) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN done = 1 THEN 1 ELSE 0 END) as completed,
          SUM(CASE WHEN done = 0 THEN 1 ELSE 0 END) as pending
        FROM tasks 
        WHERE user_id = ?
      ''', [userId]);
      
      if (result.isNotEmpty) {
        final row = result.first;
        return {
          'total': row['total'] as int? ?? 0,
          'completed': row['completed'] as int? ?? 0,
          'pending': row['pending'] as int? ?? 0,
        };
      }
      return {'total': 0, 'completed': 0, 'pending': 0};
    } catch (e) {
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }

  Future<List<Task>> searchTasks(String userId, String query) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND (title LIKE ? OR description LIKE ?)',
        whereArgs: [userId, '%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // ⬇️ CERRAR DATABASE
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}