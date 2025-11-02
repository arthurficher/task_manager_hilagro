import 'package:flutter/material.dart';
import 'package:task_manager_hilagro/features/tasks/domain/entities/task.dart';
import 'package:task_manager_hilagro/features/tasks/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

class TaskProvider extends ChangeNotifier {
  List<Task> _taskList = [];
  List<Task> _todayTasks = [];
  List<Task> _weekTasks = [];
  bool _isLoading = false;
  String? _currentUserId;
  
  final TaskRepository _repository = TaskRepository();
  final Uuid _uuid = const Uuid();

  // Getters
  String? get currentUserId => _currentUserId;
  List<Task> get taskList => _taskList;
  List<Task> get todayTasks => _todayTasks;
  List<Task> get weekTasks => _weekTasks;
  List<Task> get pendingTasks => _taskList.where((task) => !task.done).toList();
  List<Task> get completedTasks => _taskList.where((task) => task.done).toList();
  bool get isLoading => _isLoading;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    fetchTasks();
    fetchTodayTasks();
    fetchWeekTasks();
  }

  Future<void> fetchTasks() async {
    if (_currentUserId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _taskList = await _repository.getTasksByUserId(_currentUserId!);
    } catch (e) {
      dev.log('Error loading tasks from SQLite: $e');
      _taskList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTodayTasks() async {
    if (_currentUserId == null) return;
    
    try {
      _todayTasks = await _repository.getTasksForToday(_currentUserId!);
      notifyListeners();
    } catch (e) {
      dev.log('Error loading today tasks: $e');
      _todayTasks = [];
    }
  }

  Future<void> fetchWeekTasks() async {
    if (_currentUserId == null) return;
    
    try {
      _weekTasks = await _repository.getTasksForWeek(_currentUserId!);
      notifyListeners();
    } catch (e) {
      dev.log('Error loading week tasks: $e');
      _weekTasks = [];
    }
  }

  Future<void> addNewTask(dynamic taskOrTitle, [String? description, DateTime? dueDate]) async {
    if (_currentUserId == null) return;

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
        dueDate: dueDate,
        userId: _currentUserId!,
      );
    } else {
      return;
    }
    
    try {
      final success = await _repository.addTask(newTask);
      if (success) {
        _taskList.insert(0, newTask);
        await fetchTodayTasks();
        await fetchWeekTasks();
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error adding task to SQLite: $e');
    }
  }

  Future<void> onTaskDoneChange(Task task) async {
    try {
      final success = await _repository.toggleTaskCompletion(task);
      if (success) {
        final index = _taskList.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _taskList[index] = _taskList[index].copyWith(done: !_taskList[index].done);
        }
        
        await fetchTodayTasks();
        await fetchWeekTasks();
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error toggling task in SQLite: $e');
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
    
    try {
      final success = await _repository.deleteTask(taskId);
      if (success) {
        _taskList.removeWhere((task) => task.id == taskId);
        await fetchTodayTasks();
        await fetchWeekTasks();
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error removing task from SQLite: $e');
    }
  }

  Future<void> updateTask(String taskId, String title, String description, [DateTime? dueDate]) async {
    final index = _taskList.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = _taskList[index].copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
      );
      
      try {
        final success = await _repository.updateTask(updatedTask);
        if (success) {
          _taskList[index] = updatedTask;
          await fetchTodayTasks();
          await fetchWeekTasks();
          notifyListeners();
        }
      } catch (e) {
        dev.log('Error updating task in SQLite: $e');
      }
    }
  }

  Future<Map<String, int>> getTaskStats() async {
    if (_currentUserId == null) return {'total': 0, 'completed': 0, 'pending': 0};
    
    try {
      return await _repository.getTaskStatsByUserId(_currentUserId!);
    } catch (e) {
      dev.log('Error getting task stats: $e');
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    if (_currentUserId == null) return [];
    
    try {
      return await _repository.searchTasks(_currentUserId!, query);
    } catch (e) {
      dev.log('Error searching tasks: $e');
      return [];
    }
  }

  void clearTasks() {
    _taskList.clear();
    _todayTasks.clear();
    _weekTasks.clear();
    _currentUserId = null;
    notifyListeners();
  }
  
  Future<void> deleteAllUserTasks() async {
    if (_currentUserId == null) return;
    
    try {
      final success = await _repository.deleteAllTasksByUserId(_currentUserId!);
      if (success) {
        _taskList.clear();
        _todayTasks.clear();
        _weekTasks.clear();
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error deleting all user tasks: $e');
    }
  }
}
