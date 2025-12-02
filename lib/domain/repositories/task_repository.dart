import '../entities/task.dart';

abstract class TaskRepository {
  /// Returns the task with the given id, or `null` if not found.
  Future<Task?> getTaskById(String taskId);
}
