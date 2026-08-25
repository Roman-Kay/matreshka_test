import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/painters/parallelogram_painter.dart';
import '../../../../../core/ui/pressable_scale.dart';
import '../../../../pause/domain/models/player_battle_pass_progress.dart';
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
    required this.rewardStatus,
    required this.selected,
    required this.progress,
    required this.isFirstLevel,
    required this.isLastLevel,
    required this.onSelected,
    required this.onClaim,
    required this.onShowDetails,
    this.showRoadLines = true,
    this.forceLargeSize = false,
    this.visualScale = 1,
    this.availableGlowAnimation,
    this.staticGlowColor,
  });

  final int level;
  final BattlePassReward reward;
  final RewardStatus rewardStatus;
  final bool selected;
  final PlayerBattlePassProgress progress;
  final bool isFirstLevel;
  final bool isLastLevel;
  final VoidCallback onSelected;
  final VoidCallback onClaim;
  final VoidCallback onShowDetails;
  final bool showRoadLines;
  final bool forceLargeSize;
  final double visualScale;
  final Animation<double>? availableGlowAnimation;
  final Color? staticGlowColor;

  @override
  Widget build(BuildContext context) {
    final unlocked = level <= progress.currentLevel;
    final received = rewardStatus == RewardStatus.received;
    final available = rewardStatus == RewardStatus.available;
    final largeSize = available || forceLargeSize;

    return InkWell(
      onTap: onSelected,
      onLongPress: onShowDetails,
      borderRadius: BorderRadius.circular(18.h),
      child: SizedBox(
        width: 242.h,
        height: 300.h,
        child: Column(
          children: [
            SizedBox(
              height: 220.h,
              width: 242.h,
              child: Center(
                child: Transform.scale(
                  scale: visualScale,
                  alignment: Alignment.center,
                  child: RewardCardVisual(
                    reward: reward,
                    selected: selected,
                    available: available,
                    received: received,
                    largeSize: largeSize,
                    onClaim: onClaim,
                    availableGlowAnimation: availableGlowAnimation,
                    staticGlowColor: staticGlowColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            RewardProgressMarker(level: level, unlocked: unlocked, drawLeftLine: showRoadLines && !isFirstLevel, drawRightLine: showRoadLines && !isLastLevel),
          ],
        ),
      ),
    );
  }
}

class RewardCardVisual extends StatelessWidget {
  const RewardCardVisual({
    super.key,
    required this.reward,
    required this.selected,
    required this.available,
    required this.received,
    required this.largeSize,
    this.onClaim,
    this.availableGlowAnimation,
    this.staticGlowColor,
  });

  final BattlePassReward reward;
  final bool selected;
  final bool available;
  final bool received;
  final bool largeSize;
  final VoidCallback? onClaim;
  final Animation<double>? availableGlowAnimation;
  final Color? staticGlowColor;

  @override
  Widget build(BuildContext context) {
    final cardWidth = largeSize ? 242.h : 210.h;
    final cardHeight = largeSize ? 220.h : 184.h;
    final borderColor = selected
        ? AppColors.white100
        : available
        ? AppColors.green
        : AppColors.white40;
    final borderWidth = selected || available ? 4.h : 1.h;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
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
                          borderColor: animatedBorderColor ?? borderColor,
                          borderWidth: animatedBorderWidth,
                          skew: 26.h,
                          radius: 24.h,
                          glowColor: staticGlowColor ?? (available ? AppColors.green : null),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 18.h, bottom: 10.h),
                                child: Image.asset(reward.assetPath ?? AppAssets.railBirthdayMask, fit: BoxFit.contain),
                              ),
                            ),
                            if (!available)
                              Positioned(
                                left: 26.h,
                                top: 10.h,
                                child: RewardTrackIcon(track: reward.track),
                              ),
                            if (reward.amount > 1)
                              Positioned(
                                right: 28.h,
                                bottom: available ? 74.h : 12.h,
                                child: RewardAmountBadge(amount: reward.amount),
                              ),
                            if (available && onClaim != null)
                              Positioned(
                                left: 13.h,
                                bottom: 7.h,
                                child: _ClaimRewardButton(onTap: onClaim!),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (available)
              Positioned(
                left: -42.h,
                top: -42.h,
                width: cardWidth + 84.h,
                height: cardHeight + 84.h,
                child: IgnorePointer(
                  child: _AvailableRewardBorderGlow(animation: availableGlowAnimation, skew: 26.h, radius: 24.h, strokeWidth: 4.h, inset: 42.h),
                ),
              ),
            if (received)
              Positioned(
                right: 26.h,
                top: 24.h,
                child: SvgPicture.asset(AppAssets.done, width: 62.h, height: 42.h),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvailableRewardBorderGlow extends StatelessWidget {
  const _AvailableRewardBorderGlow({required this.animation, required this.skew, required this.radius, required this.strokeWidth, required this.inset});

  final Animation<double>? animation;
  final double skew;
  final double radius;
  final double strokeWidth;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final animation = this.animation;
    if (animation == null) return const SizedBox.shrink();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _AvailableRewardBorderGlowPainter(progress: animation.value, skew: skew, radius: radius, strokeWidth: strokeWidth, inset: inset),
          );
        },
      ),
    );
  }
}

class _AvailableRewardBorderGlowPainter extends CustomPainter {
  const _AvailableRewardBorderGlowPainter({required this.progress, required this.skew, required this.radius, required this.strokeWidth, required this.inset});

  final double progress;
  final double skew;
  final double radius;
  final double strokeWidth;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _roundedParallelogramPath(Size(size.width - inset * 2, size.height - inset * 2)).shift(Offset(inset, inset));
    const travelEnd = 0.56;
    const pulseEnd = 0.82;
    final pulseProgress = ((progress - travelEnd) / (pulseEnd - travelEnd)).clamp(0.0, 1.0);
    final pulseOpacity = pulseProgress < 0.5 ? pulseProgress * 2 : (1 - pulseProgress) * 2;

    if (pulseOpacity > 0) {
      final pulsePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..color = AppColors.green.withValues(alpha: 0.82 * pulseOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28.r);
      canvas.drawPath(path, pulsePaint);
    }

    if (progress > travelEnd) return;

    final metric = path.computeMetrics().first;
    final segmentLength = metric.length * 0.12;
    final travelProgress = (progress / travelEnd).clamp(0.0, 1.0);
    final segmentFadeIn = (progress / (travelEnd * 0.16)).clamp(0.0, 1.0);
    final segmentFadeOut = progress < travelEnd * 0.84 ? 1.0 : (1 - (progress - travelEnd * 0.84) / (travelEnd * 0.16)).clamp(0.0, 1.0);
    final segmentOpacity = Curves.easeOut.transform(segmentFadeIn) * segmentFadeOut;
    final head = metric.length * Curves.easeInOutSine.transform(travelProgress);
    final tail = head - segmentLength;
    final segment = Path();

    if (tail < 0) {
      segment.addPath(metric.extractPath(metric.length + tail, metric.length), Offset.zero);
      segment.addPath(metric.extractPath(0, head), Offset.zero);
    } else {
      segment.addPath(metric.extractPath(tail, head), Offset.zero);
    }

    final movingShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 14
      ..color = AppColors.green.withValues(alpha: 0.36 * segmentOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16.r);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 8
      ..color = Colors.white.withValues(alpha: 0.12 * segmentOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18.r);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * 0.55
      ..color = Colors.white.withValues(alpha: 0.18 * segmentOpacity);

    canvas.drawPath(segment, movingShadowPaint);
    canvas.drawPath(segment, glowPaint);
    canvas.drawPath(segment, linePaint);
  }

  @override
  bool shouldRepaint(_AvailableRewardBorderGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.skew != skew || oldDelegate.radius != radius || oldDelegate.strokeWidth != strokeWidth || oldDelegate.inset != inset;
  }

  Path _roundedParallelogramPath(Size size) {
    final points = [Offset(skew, 0), Offset(size.width, 0), Offset(size.width - skew, size.height), Offset(0, size.height)];
    final path = Path();

    for (var index = 0; index < points.length; index++) {
      final previous = points[(index - 1 + points.length) % points.length];
      final current = points[index];
      final next = points[(index + 1) % points.length];
      final start = _pointAlong(current, previous, radius);
      final end = _pointAlong(current, next, radius);

      if (index == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }

      path.arcToPoint(end, radius: Radius.circular(radius));
    }

    return path..close();
  }

  Offset _pointAlong(Offset from, Offset to, double distance) {
    final vector = to - from;
    final length = vector.distance;
    if (length == 0) return from;
    return from + vector / length * distance.clamp(0, length / 2);
  }
}

class _ClaimRewardButton extends StatelessWidget {
  const _ClaimRewardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: SizedBox(
        width: 198.h,
        height: 60.h,
        child: CustomPaint(
          painter: ParallelogramPainter(fillColors: const [Color(0xFF56B877), Color(0xFF56B877), Color(0xFF449660)], borderColor: AppColors.transparent, borderWidth: 0, skew: 9.h, radius: 20.h),
          child: Center(
            child: Text(
              'Забрать',
              style: TextStyle(color: AppColors.white100, fontSize: 26.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26.h),
            ),
          ),
        ),
      ),
    );
  }
}
