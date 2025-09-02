import 'package:flutter/foundation.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  TaskProvider({TaskService? taskService})
    : _taskService = taskService ?? TaskService();

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TaskModel> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();
  List<TaskModel> get pendingTasks =>
      _tasks.where((task) => task.status != TaskStatus.completed).toList();
  List<TaskModel> get todayTasks => _tasks
      .where(
        (task) =>
            task.dueDate != null && _isSameDay(task.dueDate!, DateTime.now()),
      )
      .toList();

  // Load user tasks
  Future<void> loadTasks(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final tasks = await _taskService.getUserTasks(userId);
      _tasks = tasks;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Add new task
  Future<void> addTask(TaskModel task) async {
    try {
      _clearError();

      await _taskService.addTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update existing task
  Future<void> updateTask(TaskModel task) async {
    try {
      _clearError();

      await _taskService.updateTask(task);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      _clearError();

      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(TaskModel task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.inProgress
        : TaskStatus.completed;

    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
    );

    await updateTask(updatedTask);
  }

  // Watch tasks for real-time updates
  void watchTasks(String userId) {
    // For now, just load tasks once
    // In a real implementation, you'd set up Firebase listeners
    loadTasks(userId);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
