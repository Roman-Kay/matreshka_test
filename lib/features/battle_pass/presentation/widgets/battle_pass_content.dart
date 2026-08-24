import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_state.dart';
import 'battle_pass_header.dart';
import 'premium_panel.dart';
import 'rewards/reward_rail.dart';
import 'rewards/reward_title.dart';
import 'battle_pass_completed_notice.dart';
import 'tasks_preview/tasks_preview.dart';

class BattlePassContent extends StatelessWidget {
  const BattlePassContent({
    super.key,
    required this.state,
    required this.onExitToGame,
    required this.onPurchasePremium,
    required this.onClaimAllRewards,
    required this.onClaimTask,
    required this.onSelectReward,
    required this.onClaimReward,
    required this.onDemoModeSelected,
  });

  final BattlePassState state;
  final VoidCallback onExitToGame;
  final VoidCallback onPurchasePremium;
  final VoidCallback onClaimAllRewards;
  final ValueChanged<int> onClaimTask;
  final ValueChanged<int> onSelectReward;
  final ValueChanged<int> onClaimReward;
  final ValueChanged<BattlePassDemoMode> onDemoModeSelected;

  @override
  Widget build(BuildContext context) {
    final pass = state.battlePass!;
    final selected = _selectedReward(pass, state.selectedRewardId);
    final choiceRewards = _selectedChoiceRewards(pass, state.selectedRewardId);
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final completed = state.demoMode == BattlePassDemoMode.completed;

    return Stack(
      children: [
        Padding(
          // для центровки контейнера с выбранной наградой, чтобы он был по центру bg картинки, а не по центру экрана
          padding: EdgeInsets.only(top: 105.h, right: 105.w),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Image.asset(selected?.assetPath ?? AppAssets.hero, height: 521.h, width: 521.w),
                RewardTitle(reward: selected, choiceRewards: choiceRewards, premiumLocked: premiumLocked),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PremiumPanel(pass: pass, onPurchasePremium: onPurchasePremium, onClaimAllRewards: onClaimAllRewards),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            BattlePassHeader(pass: pass, onDemoModeSelected: onDemoModeSelected, onClose: onExitToGame),
            completed ? const BattlePassCompletedNotice() : TasksPreview(tasks: pass.tasks, onTap: () => context.router.root.push(const BattlePassTasksRoute()), onClaim: onClaimTask),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 320.h,
                  child: RewardRail(state: state, onSelectReward: onSelectReward, onClaimReward: onClaimReward),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  BattlePassReward? _selectedReward(BattlePass pass, int? id) {
    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        if (reward.id == id) return reward;
      }
    }
    return null;
  }

  List<BattlePassReward> _selectedChoiceRewards(BattlePass pass, int? id) {
    if (id == null) return const [];

    for (final level in pass.season.levels) {
      final rewards = [...level.freeRewards, ...level.premiumRewards];
      if (!rewards.any((reward) => reward.id == id)) continue;
      return level.premiumRewards.length > 1 ? level.premiumRewards : const [];
    }

    return const [];
  }
}
