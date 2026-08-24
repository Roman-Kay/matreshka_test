import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';
import '../widgets/battle_pass_header.dart';
import '../widgets/premium_panel.dart';
import '../widgets/reward_rail.dart';
import '../widgets/reward_title.dart';
import '../widgets/tasks_preview.dart';

@RoutePage()
class BattlePassHomePage extends StatelessWidget {
  const BattlePassHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BattlePassCubit, BattlePassState>(
      builder: (context, state) => _BattlePassHomeContent(state: state),
    );
  }
}

class _BattlePassHomeContent extends StatelessWidget {
  const _BattlePassHomeContent({required this.state});

  final BattlePassState state;

  @override
  Widget build(BuildContext context) {
    final pass = state.battlePass!;
    final selected = _selectedReward(pass, state.selectedRewardId);
    final choiceRewards = _selectedChoiceRewards(pass, state.selectedRewardId);
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final completed = state.demoMode == BattlePassDemoMode.completed;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            BattlePassHeader(pass: pass),
            completed
                ? const BattlePassCompletedNotice()
                : TasksPreview(
                    tasks: pass.tasks,
                    onTap: () =>
                        context.pushRoute(const BattlePassTasksRoute()),
                  ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 300.h,
                  child: RewardRail(state: state),
                ),
              ),
            ),
          ],
        ),
        Padding(
          // для центровки контейнера с выбранной наградой, чтобы он был по центру bg картинки, а не по центру экрана
          padding: EdgeInsets.only(top: 105.h, right: 105.w),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Image.asset(
                  selected?.assetPath ?? AppAssets.hero,
                  height: 521.h,
                  width: 521.w,
                ),
                RewardTitle(
                  reward: selected,
                  choiceRewards: choiceRewards,
                  premiumLocked: premiumLocked,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PremiumPanel(pass: pass),
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
