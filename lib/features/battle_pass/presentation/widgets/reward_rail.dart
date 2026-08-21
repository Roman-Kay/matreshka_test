import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';

class RewardRail extends StatelessWidget {
  const RewardRail({super.key, required this.state});

  final BattlePassState state;

  @override
  Widget build(BuildContext context) {
    final pass = state.battlePass!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x553A0A0A),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
        scrollDirection: Axis.horizontal,
        children: [
          for (final level in pass.season.levels) ...[
            RewardCard(
              level: level.number,
              reward: level.freeRewards.first,
              selected: state.selectedRewardId == level.freeRewards.first.id,
            ),
            RewardCard(
              level: level.number,
              reward: level.premiumRewards.first,
              selected: state.selectedRewardId == level.premiumRewards.first.id,
            ),
          ],
        ],
      ),
    );
  }
}

class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.level,
    required this.reward,
    required this.selected,
  });

  final int level;
  final BattlePassReward reward;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final available = reward.status == RewardStatus.available;
    return Padding(
      padding: EdgeInsets.only(right: 28.w),
      child: InkWell(
        onTap: () => context.read<BattlePassCubit>().selectReward(reward.id),
        onLongPress: () => _showDetails(context),
        borderRadius: BorderRadius.circular(26.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 242.w,
          height: 290.h,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: available
                ? const Color(0x9956B877)
                : const Color(0x88530202),
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.white40,
              width: selected ? 5.r : 1.r,
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: RewardStatusChip(reward: reward),
              ),
              Expanded(
                child: Image.asset(
                  reward.assetPath ?? AppAssets.rewardTwo,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'x${reward.amount}',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              FilledButton(
                onPressed: () =>
                    context.read<BattlePassCubit>().claimReward(reward.id),
                style: FilledButton.styleFrom(
                  backgroundColor: available
                      ? AppColors.green
                      : AppColors.panel,
                ),
                child: Text(
                  reward.status == RewardStatus.received ? 'Готово' : 'Забрать',
                ),
              ),
              Text(
                '$level',
                style: TextStyle(fontSize: 22.sp, color: AppColors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ink,
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Text(
          '${reward.title}\nТип: ${reward.type.name}\nСтатус: ${reward.status.name}',
          style: TextStyle(fontSize: 22.sp),
        ),
      ),
    );
  }
}

class RewardStatusChip extends StatelessWidget {
  const RewardStatusChip({super.key, required this.reward});

  final BattlePassReward reward;

  @override
  Widget build(BuildContext context) {
    final text = switch (reward.status) {
      RewardStatus.locked =>
        reward.track == BattlePassTrack.premium ? 'Премиум' : 'Закрыто',
      RewardStatus.available => 'Можно',
      RewardStatus.received => '✓',
    };
    return Chip(
      label: Text(text),
      backgroundColor: reward.status == RewardStatus.received
          ? AppColors.green
          : AppColors.gold,
    );
  }
}
