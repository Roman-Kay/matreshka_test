import 'package:flutter/widgets.dart';

import '../../../../core/ui/badges/level_progress_badge.dart';
import '../../../pause/domain/models/player_battle_pass_progress.dart';

class BattlePassLevelBadge extends StatelessWidget {
  const BattlePassLevelBadge({super.key, required this.progress});

  final PlayerBattlePassProgress progress;

  @override
  Widget build(BuildContext context) {
    return LevelProgressBadge(level: progress.currentLevel, currentXp: progress.currentXp, nextLevelXp: progress.nextLevelXp, progressRatio: progress.ratio);
  }
}
