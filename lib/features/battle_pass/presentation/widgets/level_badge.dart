import 'package:flutter/widgets.dart';

import '../../../../core/ui/badges/level_progress_badge.dart';
import '../../domain/models/battle_pass_models.dart';

class BattlePassLevelBadge extends StatelessWidget {
  const BattlePassLevelBadge({super.key, required this.progress});

  final BattlePassProgress progress;

  @override
  Widget build(BuildContext context) {
    return LevelProgressBadge(
      level: progress.currentLevel,
      currentXp: progress.currentXp,
      nextLevelXp: progress.nextLevelXp,
      progressRatio: progress.ratio,
    );
  }
}
