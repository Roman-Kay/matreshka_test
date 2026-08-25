import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/badges/level_progress_badge.dart';
import '../../../../core/ui/buttons/header_icon_button.dart';
import '../../../../core/ui/countdown/countdown_text.dart';
import '../models/tasks_progress_summary.dart';

class TasksHeader extends StatelessWidget {
  const TasksHeader({
    super.key,
    required this.progress,
    required this.onBack,
    required this.onExit,
  });

  final TasksProgressSummary? progress;
  final VoidCallback? onBack;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final progress =
        this.progress ??
        TasksProgressSummary(
          currentLevel: 1,
          currentXp: 500,
          nextLevelXp: 1600,
          tasksRefreshAt: DateTime.now().add(
            const Duration(days: 16, hours: 12, minutes: 42),
          ),
        );

    return Padding(
      padding: EdgeInsets.only(left: 51.w, right: 80.w, top: 37.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderIconButton(assetPath: AppAssets.arrowLeft, onTap: onBack!),
          SizedBox(width: 30.w),
          LevelProgressBadge(
            level: progress.currentLevel,
            currentXp: progress.currentXp,
            nextLevelXp: progress.nextLevelXp,
            progressRatio: progress.ratio,
            style: LevelProgressBadgeStyle.premium,
          ),
          SizedBox(width: 40.w),
          Padding(
            padding: EdgeInsets.only(top: 13.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50.h,
                      width: 224.w,
                      decoration: BoxDecoration(
                        color: AppColors.white7,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.clock,
                            width: 32.r,
                            height: 32.r,
                          ),
                          SizedBox(width: 14.w),
                          CountdownText(
                            endsAt: progress.tasksRefreshAt,
                            style: TextStyle(
                              color: AppColors.white40,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.20,
                              letterSpacing: -0.26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Text(
                      'До обновления заданий',
                      style: TextStyle(
                        color: AppColors.secondary10,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                        letterSpacing: -0.26,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Задания боевого пропуска',
                  style: TextStyle(
                    color: AppColors.white40,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.30,
                    letterSpacing: -0.48,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          HeaderIconButton(
            assetPath: AppAssets.close,
            onTap: onExit ?? onBack!,
          ),
        ],
      ),
    );
  }
}
