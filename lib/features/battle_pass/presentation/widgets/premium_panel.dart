import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';
import 'premium_action_button.dart';

class PremiumPanel extends StatelessWidget {
  const PremiumPanel({super.key, required this.pass});

  final BattlePass pass;

  @override
  Widget build(BuildContext context) {
    final maxed = pass.progress.currentLevel >= pass.season.maxLevel;
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final availableRewardsCount = _availableRewardsCount(pass);
    if (premiumLocked) {
      return const _ElitePassPanel();
    }

    return _LevelUpPanel(
      maxed: maxed,
      canClaimAll: maxed && availableRewardsCount > 3,
      onClaimAll: () =>
          context.read<BattlePassCubit>().claimAllAvailableRewards(),
      onLevelUp: () => context.read<BattlePassCubit>().purchasePremium(),
    );
  }

  int _availableRewardsCount(BattlePass pass) {
    var count = 0;
    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        if (reward.status == RewardStatus.available) count += 1;
      }
    }
    return count;
  }
}

class _LevelUpPanel extends StatelessWidget {
  const _LevelUpPanel({
    required this.maxed,
    required this.canClaimAll,
    required this.onClaimAll,
    required this.onLevelUp,
  });

  final bool maxed;
  final bool canClaimAll;
  final VoidCallback onClaimAll;
  final VoidCallback onLevelUp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(AppAssets.levelUp, width: 605.w, height: 690.h),
        Positioned(
          top: 367.h,
          right: 80.w,
          child: Column(
            children: [
              Text(
                'Повышение уровня',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFFD149),
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.30,
                  letterSpacing: -0.36,
                ),
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: 400.w,
                child: Text(
                  'Повышай уровень боевого пропуска и забирай новые награды!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white70,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.22,
                  ),
                ),
              ),
              SizedBox(height: maxed ? 28.h : 53.h),
              if (maxed) ...[
                const _MaxLevelButton(),
                if (canClaimAll) ...[
                  SizedBox(height: 24.h),
                  _ClaimAllRewardsButton(onPressed: onClaimAll),
                ],
              ] else if (canClaimAll)
                _ClaimAllRewardsButton(onPressed: onClaimAll)
              else
                PremiumActionButton(
                  iconAsset: AppAssets.arrowLevelUp,
                  text: 'Повысить уровень',
                  onPressed: onLevelUp,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ElitePassPanel extends StatelessWidget {
  const _ElitePassPanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 570.w,
      height: 660.h,
      child: Stack(
        children: [
          Image.asset(
            AppAssets.woman,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          Positioned(
            top: 370.h,
            right: 70.w,
            child: Column(
              children: [
                Text(
                  'Элитный пропуск',
                  style: TextStyle(
                    color: const Color(0xFFFFD149),
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.30,
                    letterSpacing: -0.36,
                  ),
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  width: 400.w,
                  child: Text(
                    'Прокачай боевой пропуск и забери четкие скины, аксессуары и многое другое!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white70,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.20,
                      letterSpacing: -0.22,
                    ),
                  ),
                ),
                SizedBox(height: 27.h),
                PremiumActionButton(
                  iconAsset: AppAssets.premium,
                  text: 'Прокачать',
                  onPressed: () =>
                      context.read<BattlePassCubit>().purchasePremium(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxLevelButton extends StatelessWidget {
  const _MaxLevelButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.w,
      height: 100.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x19E9E9F3),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(48.w, 30.h, 48.w, 34.h),
          child: Center(
            child: Text(
              'Достигнут максимальный уровень',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0x66E9E9F3),
                fontSize: 22.sp,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClaimAllRewardsButton extends StatelessWidget {
  const _ClaimAllRewardsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 400.w,
        padding: EdgeInsets.fromLTRB(36.w, 20.h, 36.w, 23.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF56B876), Color(0xFF44955F)],
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Забрать все награды',
              style: TextStyle(
                color: AppColors.white100,
                fontSize: 26.sp,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
