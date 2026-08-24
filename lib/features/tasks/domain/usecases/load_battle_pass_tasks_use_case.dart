import '../models/task.dart';
import '../repositories/tasks_repository.dart';

final class LoadBattlePassTasksUseCase {
  const LoadBattlePassTasksUseCase(this._repository);

  final TasksRepository _repository;

  Future<List<Task>> call() => _repository.loadBattlePassTasks();
}
