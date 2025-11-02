import 'package:task_manager_hilagro/core/database/database_helper.dart';
import 'package:task_manager_hilagro/features/tasks/domain/entities/task.dart';

class TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Task>> getAllTasks() async {
    return await _databaseHelper.getAllTasks();
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    return await _databaseHelper.getTasksByUserId(userId);
  }

  Future<List<Task>> getPendingTasksByUserId(String userId) async {
    return await _databaseHelper.getPendingTasksByUserId(userId);
  }

  Future<List<Task>> getCompletedTasksByUserId(String userId) async {
    return await _databaseHelper.getCompletedTasksByUserId(userId);
  }

  Future<bool> addTask(Task task) async {
    final result = await _databaseHelper.insertTask(task);
    return result > 0;
  }

  Future<bool> updateTask(Task task) async {
    final result = await _databaseHelper.updateTask(task);
    return result > 0;
  }

  Future<bool> deleteTask(String taskId) async {
    final result = await _databaseHelper.deleteTask(taskId);
    return result > 0;
  }

  Future<bool> completeTask(Task task) async {
    final completedTask = task.copyWith(done: true);
    return await updateTask(completedTask);
  }

  Future<bool> toggleTaskCompletion(Task task) async {
    final toggledTask = task.copyWith(done: !task.done);
    return await updateTask(toggledTask);
  }

  Future<int> getTaskCountByUserId(String userId) async {
    return await _databaseHelper.getTaskCountByUserId(userId);
  }

  Future<Map<String, int>> getTaskStatsByUserId(String userId) async {
    return await _databaseHelper.getTaskStatsByUserId(userId);
  }

  Future<List<Task>> searchTasks(String userId, String query) async {
    return await _databaseHelper.searchTasks(userId, query);
  }

  Future<bool> deleteAllTasksByUserId(String userId) async {
    final result = await _databaseHelper.deleteAllTasksByUserId(userId);
    return result > 0;
  }
}
