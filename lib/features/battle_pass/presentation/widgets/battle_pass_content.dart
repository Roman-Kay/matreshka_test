import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../app/app_router.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_state.dart';
import 'battle_pass_header.dart';
import 'premium_panel.dart';
import 'photo_anchored_reward_preview.dart';
import 'rewards/reward_rail.dart';
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
  static const Size _backgroundDesignSize = Size(703, 678);
  static const Offset _rewardFrameCenter = Offset(385, 280);
  static const double _rewardFrameSize = 512;

  @override
  Widget build(BuildContext context) {
    final pass = state.battlePass!;
    final selected = _selectedReward(pass, state.selectedRewardId);
    final choiceRewards = _selectedChoiceRewards(pass, state.selectedRewardId);
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final completed = state.demoMode == BattlePassDemoMode.completed;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 440.h,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment(0.50, 0), end: Alignment(0.50, 1), colors: [Color(0x00450D05), Color(0xB2350D03), Color(0xFF220401)]),
            ),
          ),
        ),
        Positioned.fill(
          child: PhotoAnchoredRewardPreview(
            designSize: _backgroundDesignSize,
            designCenter: _rewardFrameCenter,
            designSizePx: _rewardFrameSize,
            reward: selected,
            choiceRewards: choiceRewards,
            premiumLocked: premiumLocked,
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
            completed ? const BattlePassCompletedNotice() : TasksPreview(tasks: pass.tasks, onTap: () => context.router.push(const BattlePassTasksRoute()), onClaim: onClaimTask),
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
