import 'package:flutter/material.dart';
import 'package:task_manager_hilagro/features/tasks/domain/entities/task.dart';
import 'package:task_manager_hilagro/features/tasks/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _taskList = [];
  bool _isLoading = false;
  String? _currentUserId;
  
  final TaskRepository _repository = TaskRepository();
  final Uuid _uuid = const Uuid();

  // Getters
  String? get currentUserId => _currentUserId;
  List<Task> get taskList => _taskList;
  List<Task> get pendingTasks => _taskList.where((task) => !task.done).toList();
  List<Task> get completedTasks => _taskList.where((task) => task.done).toList();
  bool get isLoading => _isLoading;

  void setCurrentUser(String userId) {
    print('TaskProvider: Setting current user to $userId');
    _currentUserId = userId;
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    if (_currentUserId == null) return;
    
    print('TaskProvider: Fetching tasks from SQLite for user $_currentUserId');
    _isLoading = true;
    notifyListeners();

    try {
      _taskList = await _repository.getTasksByUserId(_currentUserId!);
      print('TaskProvider: Loaded ${_taskList.length} tasks from SQLite');
    } catch (e) {
      debugPrint('Error loading tasks from SQLite: $e');
      _taskList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNewTask(dynamic taskOrTitle, [String? description]) async {
    if (_currentUserId == null) {
      print('TaskProvider: Cannot add task - no current user set');
      return;
    }

    Task newTask;
    
    if (taskOrTitle is Task) {
      newTask = taskOrTitle.copyWith(
        id: _uuid.v4(),
        userId: _currentUserId!,
        createdAt: DateTime.now(),
      );
    } else if (taskOrTitle is String) {
      newTask = Task(
        id: _uuid.v4(),
        title: taskOrTitle,
        description: description ?? '',
        createdAt: DateTime.now(),
        userId: _currentUserId!,
      );
    } else {
      return;
    }

    print('TaskProvider: Adding new task to SQLite: ${newTask.title}');
    
    try {
      final success = await _repository.addTask(newTask);
      if (success) {
        _taskList.insert(0, newTask); 
        print('TaskProvider: Task added successfully to SQLite');
        notifyListeners();
      } else {
        print('TaskProvider: Failed to add task to SQLite');
      }
    } catch (e) {
      debugPrint('Error adding task to SQLite: $e');
    }
  }

  Future<void> onTaskDoneChange(Task task) async {
    try {
      final success = await _repository.toggleTaskCompletion(task);
      if (success) {
        final index = _taskList.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _taskList[index] = _taskList[index].copyWith(done: !_taskList[index].done);
          print('TaskProvider: Task ${task.title} toggled to ${_taskList[index].done} in SQLite');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error toggling task in SQLite: $e');
    }
  }

  Future<void> toggleTaskDone(String taskId) async {
    final task = _taskList.firstWhere((task) => task.id == taskId);
    await onTaskDoneChange(task);
  }

  Future<void> removeTask(dynamic taskOrId) async {
    String taskId;
    
    if (taskOrId is Task) {
      taskId = taskOrId.id;
    } else if (taskOrId is String) {
      taskId = taskOrId;
    } else {
      return;
    }

    print('TaskProvider: Removing task from SQLite with ID: $taskId');
    
    try {
      final success = await _repository.deleteTask(taskId);
      if (success) {
        _taskList.removeWhere((task) => task.id == taskId);
        print('TaskProvider: Task removed successfully from SQLite');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing task from SQLite: $e');
    }
  }

  Future<void> updateTask(String taskId, String title, String description) async {
    final index = _taskList.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = _taskList[index].copyWith(
        title: title,
        description: description,
      );
      
      try {
        final success = await _repository.updateTask(updatedTask);
        if (success) {
          _taskList[index] = updatedTask;
          print('TaskProvider: Task updated successfully in SQLite');
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error updating task in SQLite: $e');
      }
    }
  }

  Future<Map<String, int>> getTaskStats() async {
    if (_currentUserId == null) return {'total': 0, 'completed': 0, 'pending': 0};
    
    try {
      return await _repository.getTaskStatsByUserId(_currentUserId!);
    } catch (e) {
      debugPrint('Error getting task stats: $e');
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    if (_currentUserId == null) return [];
    
    try {
      return await _repository.searchTasks(_currentUserId!, query);
    } catch (e) {
      debugPrint('Error searching tasks: $e');
      return [];
    }
  }

  void clearTasks() {
    print('TaskProvider: Clearing all tasks');
    _taskList.clear();
    _currentUserId = null;
    notifyListeners();
  }
  
  Future<void> deleteAllUserTasks() async {
    if (_currentUserId == null) return;
    
    try {
      final success = await _repository.deleteAllTasksByUserId(_currentUserId!);
      if (success) {
        _taskList.clear();
        print('TaskProvider: All user tasks deleted from SQLite');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting all user tasks: $e');
    }
  }
}
