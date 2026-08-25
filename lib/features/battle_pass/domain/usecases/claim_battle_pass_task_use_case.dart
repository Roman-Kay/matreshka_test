import '../../../tasks/domain/models/task.dart';
import '../models/battle_pass_models.dart';

final class ClaimBattlePassTaskResult {
  const ClaimBattlePassTaskResult({required this.pass, required this.message});

  final BattlePass pass;
  final String message;
}

final class ClaimBattlePassTaskUseCase {
  const ClaimBattlePassTaskUseCase();

  ClaimBattlePassTaskResult? call(BattlePass pass, int taskId) {
    final taskIndex = pass.tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return null;

    final task = pass.tasks[taskIndex];
    if (!task.canClaim) return null;

    final tasks = [...pass.tasks];
    tasks[taskIndex] = task.copyWith(status: TaskStatus.claimed);

    final rewardAmount = task.totalRewardAmount;
    final nextXp = pass.progress.currentXp + rewardAmount;
    final leveledUp = nextXp >= pass.progress.nextLevelXp;
    final progress = pass.progress.copyWith(
      currentLevel: leveledUp ? (pass.progress.currentLevel + 1).clamp(1, pass.season.maxLevel) : pass.progress.currentLevel,
      currentXp: leveledUp ? nextXp - pass.progress.nextLevelXp : nextXp,
    );

    return ClaimBattlePassTaskResult(
      pass: pass.copyWith(
        playerState: pass.playerState.copyWith(progress: progress),
        tasks: tasks,
      ),
      message: '+$rewardAmount опыта Battle Pass',
    );
  }
}
