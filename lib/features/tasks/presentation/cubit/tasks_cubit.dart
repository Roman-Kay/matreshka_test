import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/tasks_repository.dart';
import '../../domain/models/task.dart';
import 'tasks_state.dart';

final class TasksCubit extends Cubit<TasksState> {
  TasksCubit(TasksRepository repository) : _repository = repository, super(const TasksState.initial());

  final TasksRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: TasksViewStatus.loading, clearMessage: true));
    try {
      final tasks = await _repository.loadBattlePassTasks();
      emit(state.copyWith(status: TasksViewStatus.loaded, tasks: tasks, clearMessage: true));
    } on Object {
      emit(state.copyWith(status: TasksViewStatus.failure, message: 'Не удалось загрузить задания'));
    }
  }

  Future<void> refresh() => load();

  void clear() => emit(state.copyWith(tasks: const []));

  void claimTask(int taskId) {
    final tasks = state.tasks;
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final updated = List<Task>.from(tasks);
    final task = updated[index];
    if (!task.canClaim) return;
    updated[index] = task.copyWith(status: TaskStatus.claimed);
    emit(state.copyWith(tasks: updated, message: 'Награда получена'));
  }
}
