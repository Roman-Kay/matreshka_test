import '../../domain/models/task.dart';

enum TasksViewStatus { initial, loading, loaded, failure }

final class TasksState {
  const TasksState({required this.status, this.tasks = const [], this.message});

  const TasksState.initial() : status = TasksViewStatus.initial, tasks = const [], message = null;

  final TasksViewStatus status;
  final List<Task> tasks;
  final String? message;

  TasksState copyWith({TasksViewStatus? status, List<Task>? tasks, String? message, bool clearMessage = false}) {
    return TasksState(status: status ?? this.status, tasks: tasks ?? this.tasks, message: clearMessage ? null : message ?? this.message);
  }
}
