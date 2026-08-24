import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/tasks_progress_summary.dart';
import 'tasks_header_icon_button.dart';

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
        const TasksProgressSummary(
          currentLevel: 1,
          currentXp: 500,
          nextLevelXp: 1600,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          TasksHeaderIconButton(assetPath: AppAssets.arrowLeft, onTap: onBack!),
          SizedBox(width: 40.w),
        ],
        _TasksLevelBadge(progress: progress),
        SizedBox(width: 40.w),
        Padding(
          padding: EdgeInsets.only(top: 13.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: const Color(0x11E9E9F3),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.clock,
                          width: 32.r,
                          height: 32.r,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white40,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          '15д 12ч 42м',
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
                      color: const Color(0xFF398652),
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
        if (onExit != null || onBack != null)
          TasksHeaderIconButton(
            assetPath: AppAssets.close,
            onTap: onExit ?? onBack!,
          ),
      ],
    );
  }
}

class _TasksLevelBadge extends StatelessWidget {
  const _TasksLevelBadge({required this.progress});

  final TasksProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.w,
      height: 124.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dark,
        border: Border.all(color: AppColors.orange, width: 4.r),
      ),
      child: Center(
        child: Text(
          '${progress.currentLevel}',
          style: TextStyle(
            color: AppColors.white100,
            fontSize: 42.sp,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
