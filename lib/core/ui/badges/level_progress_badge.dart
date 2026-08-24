import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../theme/app_colors.dart';

class LevelProgressBadge extends StatelessWidget {
  const LevelProgressBadge({super.key, required this.level, required this.currentXp, required this.nextLevelXp, required this.progressRatio, this.style = LevelProgressBadgeStyle.standard});

  final int level;
  final int currentXp;
  final int nextLevelXp;
  final double progressRatio;
  final LevelProgressBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = style._colors;
    return SizedBox(
      width: 130.w,
      child: Column(
        children: [
          SizedBox(
            width: 100.r,
            height: 100.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: progressRatio, strokeWidth: 8.r, color: colors.progress, backgroundColor: colors.progressBackground),
                Text(
                  '$level',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.level, fontSize: 42.sp, fontWeight: FontWeight.w600, height: 1.30, letterSpacing: -0.42),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$currentXp',
                  style: TextStyle(color: colors.currentXp, fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
                ),
                TextSpan(
                  text: ' / $nextLevelXp',
                  style: TextStyle(color: colors.nextLevelXp, fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum LevelProgressBadgeStyle {
  standard,
  premium;

  _LevelProgressBadgeColors get _colors {
    return switch (this) {
      LevelProgressBadgeStyle.standard => const _LevelProgressBadgeColors(
        level: AppColors.white100,
        currentXp: AppColors.white100,
        nextLevelXp: AppColors.white40,
        progress: AppColors.grey,
        progressBackground: AppColors.white10,
      ),
      LevelProgressBadgeStyle.premium => const _LevelProgressBadgeColors(
        level: Color(0xFFE3BA47),
        currentXp: Color(0xFFE3BA47),
        nextLevelXp: Color(0x66E3BA47),
        progress: Color(0xFFE3BA47),
        progressBackground: AppColors.white10,
      ),
    };
  }
}

final class _LevelProgressBadgeColors {
  const _LevelProgressBadgeColors({required this.level, required this.currentXp, required this.nextLevelXp, required this.progress, required this.progressBackground});

  final Color level;
  final Color currentXp;
  final Color nextLevelXp;
  final Color progress;
  final Color progressBackground;
}
