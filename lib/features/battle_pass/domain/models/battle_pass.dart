import '../../../tasks/domain/models/task.dart';
import 'battle_pass_enums.dart';
import 'battle_pass_progress.dart';
import 'battle_pass_season.dart';

final class BattlePass {
  const BattlePass({
    required this.season,
    required this.progress,
    required this.premiumStatus,
    required this.tasks,
  });

  final BattlePassSeason season;
  final BattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final List<Task> tasks;

  BattlePass copyWith({
    BattlePassSeason? season,
    BattlePassProgress? progress,
    PremiumStatus? premiumStatus,
    List<Task>? tasks,
  }) {
    return BattlePass(
      season: season ?? this.season,
      progress: progress ?? this.progress,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      tasks: tasks ?? this.tasks,
    );
  }
}
