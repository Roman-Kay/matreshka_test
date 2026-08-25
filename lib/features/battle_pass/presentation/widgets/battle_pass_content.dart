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

class BattlePassContent extends StatefulWidget {
  const BattlePassContent({
    super.key,
    required this.state,
    required this.entranceReplayToken,
    required this.onExitToGame,
    required this.onPurchasePremium,
    required this.onClaimAllRewards,
    required this.onClaimTask,
    required this.onSelectReward,
    required this.onClaimReward,
    required this.onDemoModeSelected,
  });

  final BattlePassState state;
  final int entranceReplayToken;
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
  State<BattlePassContent> createState() => _BattlePassContentState();
}

class _BattlePassContentState extends State<BattlePassContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant BattlePassContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entranceReplayToken != oldWidget.entranceReplayToken) {
      _entranceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pass = widget.state.battlePass!;
    final selected = _selectedReward(pass, widget.state.selectedRewardId);
    final choiceRewards = _selectedChoiceRewards(
      pass,
      widget.state.selectedRewardId,
    );
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final completed = widget.state.demoMode == BattlePassDemoMode.completed;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 440.h,
          child: _EntranceTransition(
            animation: _entranceController,
            interval: const Interval(0.00, 0.62, curve: Curves.easeOutCubic),
            beginOffset: Offset(0, 80.h),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0),
                  end: Alignment(0.50, 1),
                  colors: [
                    Color(0x00450D05),
                    Color(0xB2350D03),
                    Color(0xFF220401),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: _EntranceTransition(
            animation: _entranceController,
            interval: const Interval(0.12, 0.74, curve: Curves.easeOutCubic),
            beginOffset: Offset(0, -72.h),
            beginScale: 0.96,
            child: PhotoAnchoredRewardPreview(
              designSize: BattlePassContent._backgroundDesignSize,
              designCenter: BattlePassContent._rewardFrameCenter,
              designSizePx: BattlePassContent._rewardFrameSize,
              reward: selected,
              choiceRewards: choiceRewards,
              premiumLocked: premiumLocked,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: _EntranceTransition(
            animation: _entranceController,
            interval: const Interval(0.16, 0.82, curve: Curves.easeOutCubic),
            beginOffset: Offset(160.w, 0),
            child: PremiumPanel(
              pass: pass,
              onPurchasePremium: widget.onPurchasePremium,
              onClaimAllRewards: widget.onClaimAllRewards,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            _EntranceTransition(
              animation: _entranceController,
              interval: const Interval(0.04, 0.66, curve: Curves.easeOutCubic),
              beginOffset: Offset(0, -96.h),
              child: BattlePassHeader(
                pass: pass,
                onDemoModeSelected: widget.onDemoModeSelected,
                onClose: widget.onExitToGame,
              ),
            ),
            _EntranceTransition(
              animation: _entranceController,
              interval: const Interval(0.10, 0.76, curve: Curves.easeOutCubic),
              beginOffset: Offset(-160.w, 0),
              child: completed
                  ? const BattlePassCompletedNotice()
                  : TasksPreview(
                      tasks: pass.tasks,
                      onTap: _openTasks,
                      onClaim: widget.onClaimTask,
                    ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _EntranceTransition(
                  animation: _entranceController,
                  interval: const Interval(
                    0.22,
                    1.00,
                    curve: Curves.easeOutCubic,
                  ),
                  beginOffset: Offset(0, 180.h),
                  child: SizedBox(
                    height: 320.h,
                    child: RewardRail(
                      state: widget.state,
                      onSelectReward: widget.onSelectReward,
                      onClaimReward: widget.onClaimReward,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openTasks() async {
    await context.router.push(const BattlePassTasksRoute());
    if (!mounted) return;
    _entranceController.forward(from: 0);
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

class _EntranceTransition extends StatelessWidget {
  const _EntranceTransition({
    required this.animation,
    required this.interval,
    required this.beginOffset,
    required this.child,
    this.beginScale = 1,
  });

  final Animation<double> animation;
  final Interval interval;
  final Offset beginOffset;
  final double beginScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = interval.transform(animation.value);
        final opacity = progress.clamp(0.0, 1.0);
        final offset = Offset.lerp(beginOffset, Offset.zero, progress)!;
        final scale = beginScale + (1 - beginScale) * progress;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}
