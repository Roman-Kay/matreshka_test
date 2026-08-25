import '../../../../core/constants/app_assets.dart';
import '../../domain/models/task.dart';
import '../../domain/repositories/tasks_repository.dart';

final class MockTasksRepository implements TasksRepository {
  const MockTasksRepository();

  @override
  Future<List<Task>> loadBattlePassTasks() async {
    return [
      Task(id: 1, title: 'Пробегите 100 метров по городу в классическом режиме.', rewardTitle: 'Опыт БП', rewardAmount: 25, currentProgress: 40, requiredProgress: 100, rewardAssetPath: AppAssets.xp),
      Task(
        id: 2,
        title: 'Проедьте 200 метров на любом транспорте.',
        rewardTitle: 'Опыт БП',
        rewardAmount: 100,
        currentProgress: 200,
        requiredProgress: 200,
        rewardAssetPath: AppAssets.xp,
        status: TaskStatus.claimed,
      ),
      Task(
        id: 3,
        title: 'Оплатите 1 штраф ПДД в участке или через терминал.',
        rewardTitle: 'Опыт БП',
        rewardAmount: 250,
        currentProgress: 1,
        requiredProgress: 1,
        rewardAssetPath: AppAssets.xp,
        status: TaskStatus.readyToClaim,
      ),
      Task(id: 4, title: 'Заработайте 500 рублей на любой легальной работе.', rewardTitle: 'Опыт БП', rewardAmount: 25, currentProgress: 120, requiredProgress: 500, rewardAssetPath: AppAssets.xp),
      Task(id: 5, title: 'Используйте энергетик 3 раза во время RP-сессии.', rewardTitle: 'Опыт БП', rewardAmount: 25, currentProgress: 1, requiredProgress: 3, rewardAssetPath: AppAssets.xp),
    ];
  }
}
