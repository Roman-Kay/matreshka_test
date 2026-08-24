import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/painters/parallelogram_painter.dart';
import '../../../domain/models/battle_pass_models.dart';
import 'reward_amount_badge.dart';
import 'reward_progress_marker.dart';
import 'reward_rarity_style.dart';
import 'reward_track_icon.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.level,
    required this.reward,
    required this.selected,
    required this.progress,
    required this.isFirstLevel,
    required this.isLastLevel,
    required this.onSelected,
    required this.onClaim,
    required this.onShowDetails,
    this.showRoadLines = true,
    this.forceLargeSize = false,
  });

  final int level;
  final BattlePassReward reward;
  final bool selected;
  final BattlePassProgress progress;
  final bool isFirstLevel;
  final bool isLastLevel;
  final VoidCallback onSelected;
  final VoidCallback onClaim;
  final VoidCallback onShowDetails;
  final bool showRoadLines;
  final bool forceLargeSize;

  @override
  Widget build(BuildContext context) {
    final unlocked = level <= progress.currentLevel;
    final received = reward.status == RewardStatus.received;
    final available = reward.status == RewardStatus.available;
    final largeSize = available || forceLargeSize;
    final cardWidth = largeSize ? 242.w : 210.w;
    final cardHeight = largeSize ? 220.h : 184.h;
    final borderColor = selected
        ? AppColors.white100
        : available
        ? AppColors.green
        : AppColors.white40;
    final borderWidth = selected || available ? 4.r : 1.r;

    return InkWell(
      onTap: onSelected,
      onLongPress: onShowDetails,
      borderRadius: BorderRadius.circular(18.r),
      child: SizedBox(
        width: 242.w,
        height: 300.h,
        child: Column(
          children: [
            SizedBox(
              height: 220.h,
              width: 242.w,
              child: Center(
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Center(
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: received ? 0.5 : 1,
                          child: TweenAnimationBuilder<Color?>(
                            tween: ColorTween(end: borderColor),
                            duration: const Duration(milliseconds: 180),
                            builder: (context, animatedBorderColor, _) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(end: borderWidth),
                                duration: const Duration(milliseconds: 180),
                                builder: (context, animatedBorderWidth, _) {
                                  return CustomPaint(
                                    painter: ParallelogramPainter(
                                      fillColors: reward.rarity.gradientColors,
                                      borderColor:
                                          animatedBorderColor ?? borderColor,
                                      borderWidth: animatedBorderWidth,
                                      skew: 26.w,
                                      radius: 24.r,
                                      glowColor: available
                                          ? AppColors.green
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: 18.h,
                                              bottom: 10.h,
                                            ),
                                            child: Image.asset(
                                              reward.assetPath ??
                                                  AppAssets.rewardTwo,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        if (!available)
                                          Positioned(
                                            left: 26.w,
                                            top: 10.h,
                                            child: RewardTrackIcon(
                                              track: reward.track,
                                            ),
                                          ),
                                        if (reward.amount > 1)
                                          Positioned(
                                            right: 28.w,
                                            bottom: available ? 70.h : 12.h,
                                            child: RewardAmountBadge(
                                              amount: reward.amount,
                                            ),
                                          ),
                                        if (available)
                                          Positioned(
                                            left: 13.w,
                                            bottom: 14.h,
                                            child: _ClaimRewardButton(
                                              onTap: onClaim,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (received)
                          Positioned(
                            right: 26.w,
                            top: 24.h,
                            child: SvgPicture.asset(
                              AppAssets.done,
                              width: 62.w,
                              height: 42.h,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            RewardProgressMarker(
              level: level,
              unlocked: unlocked,
              drawLeftLine: showRoadLines && !isFirstLevel,
              drawRightLine: showRoadLines && !isLastLevel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimRewardButton extends StatelessWidget {
  const _ClaimRewardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 198.w,
        height: 60.h,
        child: CustomPaint(
          painter: ParallelogramPainter(
            fillColors: const [
              Color(0xFF56B877),
              Color(0xFF56B877),
              Color(0xFF449660),
            ],
            borderColor: AppColors.transparent,
            borderWidth: 0,
            skew: 9.w,
            radius: 20.r,
          ),
          child: Center(
            child: Text(
              'Забрать',
              style: TextStyle(
                color: AppColors.white100,
                fontSize: 26.sp,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
