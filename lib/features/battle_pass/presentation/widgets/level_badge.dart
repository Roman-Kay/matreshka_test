import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';

class BattlePassLevelBadge extends StatelessWidget {
  const BattlePassLevelBadge({super.key, required this.progress});

  final BattlePassProgress progress;

  @override
  Widget build(BuildContext context) {
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
                CircularProgressIndicator(
                  value: progress.ratio,
                  strokeWidth: 8.r,
                  color: AppColors.grey,
                  backgroundColor: AppColors.white10,
                ),
                Text(
                  '${progress.currentLevel}',
                  style: TextStyle(
                    color: AppColors.white100,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.30,
                    letterSpacing: -0.42,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${progress.currentXp}',
                  style: TextStyle(
                    color: AppColors.white100,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.22,
                  ),
                ),
                TextSpan(
                  text: ' / ${progress.nextLevelXp}',
                  style: TextStyle(
                    color: AppColors.white40,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.22,
                  ),
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
