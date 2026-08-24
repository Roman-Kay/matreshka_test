import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../tasks/domain/models/task.dart';

class TaskPreviewActionButton extends StatelessWidget {
  const TaskPreviewActionButton({
    super.key,
    required this.task,
    required this.onOpenTasks,
    required this.onClaim,
  });

  final Task task;
  final VoidCallback onOpenTasks;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final isClaim = task.canClaim;
    final isClaimed = task.claimed;

    return GestureDetector(
      onTap: isClaim ? onClaim : onOpenTasks,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 320.w,
            height: isClaim ? null : 74.h,
            padding: isClaim
                ? EdgeInsets.fromLTRB(36.w, 20.h, 36.w, 23.h)
                : null,
            decoration: BoxDecoration(
              color: isClaim ? null : AppColors.white10,
              gradient: isClaim
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF55B675), Color(0xFF449761)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16.w,
              children: [
                if (!isClaim)
                  SvgPicture.asset(AppAssets.tasks, width: 30.r, height: 30.r),
                Text(
                  isClaim ? 'Забрать опыт' : 'Задания',
                  style: TextStyle(
                    color: isClaim
                        ? const Color(0xFF68C286)
                        : AppColors.white100,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.26,
                  ),
                ),
              ],
            ),
          ),
          if (isClaimed)
            Positioned(
              right: -16.w,
              top: -26.h,
              child: Image.asset(AppAssets.danger, width: 58.r, height: 58.r),
            ),
        ],
      ),
    );
  }
}
