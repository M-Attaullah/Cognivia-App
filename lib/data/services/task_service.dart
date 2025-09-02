import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get all tasks for a user
  Future<List<TaskModel>> getUserTasks(String userId) async {
    try {
      final snapshot = await _database.child('tasks').child(userId).get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<TaskModel> tasks = [];

        data.forEach((key, value) {
          final taskMap = Map<String, dynamic>.from(value as Map);
          taskMap['id'] = key;
          tasks.add(TaskModel.fromJson(taskMap));
        });

        return tasks;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get user tasks: $e');
    }
  }

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    try {
      if (currentUserId == null) throw Exception('User not logged in');

      await _database
          .child('tasks')
          .child(currentUserId!)
          .push()
          .set(task.toJson());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    try {
      if (currentUserId == null) throw Exception('User not logged in');

      await _database
          .child('tasks')
          .child(currentUserId!)
          .child(task.id)
          .update(task.toJson());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      if (currentUserId == null) throw Exception('User not logged in');

      await _database
          .child('tasks')
          .child(currentUserId!)
          .child(taskId)
          .remove();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      if (currentUserId == null) throw Exception('User not logged in');

      final snapshot = await _database
          .child('tasks')
          .child(currentUserId!)
          .child(taskId)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final taskData = Map<String, dynamic>.from(snapshot.value as Map);
        final task = TaskModel.fromJson(taskData);

        final updatedTask = task.copyWith(
          status: task.status == TaskStatus.completed
              ? TaskStatus.inProgress
              : TaskStatus.completed,
        );

        await _database
            .child('tasks')
            .child(currentUserId!)
            .child(taskId)
            .update(updatedTask.toJson());
      }
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  // Get tasks by status
  Future<List<TaskModel>> getTasksByStatus(
    String userId,
    TaskStatus status,
  ) async {
    try {
      final allTasks = await getUserTasks(userId);
      return allTasks.where((task) => task.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by status: $e');
    }
  }

  // Get tasks due today
  Future<List<TaskModel>> getTodayTasks(String userId) async {
    try {
      final allTasks = await getUserTasks(userId);
      final today = DateTime.now();

      return allTasks
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.year == today.year &&
                task.dueDate!.month == today.month &&
                task.dueDate!.day == today.day,
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get today tasks: $e');
    }
  }

  // Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    try {
      final allTasks = await getUserTasks(userId);
      final now = DateTime.now();

      return allTasks
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isBefore(now) &&
                task.status != TaskStatus.completed,
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue tasks: $e');
    }
  }
}
