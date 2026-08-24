import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';

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
                _PremiumActionButton(
                  big: true,
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
                _PremiumActionButton(
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

class _PremiumActionButton extends StatefulWidget {
  const _PremiumActionButton({
    required this.iconAsset,
    required this.text,
    required this.onPressed,
    this.big = false,
  });

  final String iconAsset;
  final String text;
  final bool big;

  final VoidCallback? onPressed;

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 400.w,
        height: widget.big ? 100.h : 78.h,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: const [
                    BoxShadow(color: Color(0xB2FF8900), blurRadius: 41.5),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEFCB4B), Color(0xFFDE7F28)],
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FractionalTranslation(
                      translation: Offset(_controller.value * 2 - 1, 0),
                      child: child,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.42),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    widget.iconAsset,
                    width: 36.r,
                    height: 36.r,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF3B0B0B),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF3B0B0B),
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
