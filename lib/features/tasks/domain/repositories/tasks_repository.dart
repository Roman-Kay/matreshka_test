import '../models/task.dart';

abstract interface class TasksRepository {
  Future<List<Task>> loadBattlePassTasks();
}
