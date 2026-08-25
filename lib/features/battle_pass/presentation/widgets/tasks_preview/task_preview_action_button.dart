import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../tasks/domain/models/task.dart';

class TaskPreviewActionButton extends StatelessWidget {
  const TaskPreviewActionButton({super.key, required this.task, required this.onOpenTasks, required this.onClaim});

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
            width: 320.r,
            height: isClaim ? null : 74.r,
            padding: isClaim ? EdgeInsets.fromLTRB(36.r, 20.r, 36.r, 23.r) : null,
            decoration: BoxDecoration(
              color: isClaim ? null : AppColors.white10,
              gradient: isClaim
                  ? LinearGradient(begin: Alignment(0.50, 0.00), end: Alignment(0.50, 1.00), colors: [Color(0xFF55B675).withValues(alpha: 0.4), Color(0xFF449761).withValues(alpha: 0.4)])
                  : null,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16.r,
              children: [
                if (!isClaim) SvgPicture.asset(AppAssets.tasks, width: 30.r, height: 30.r),
                Text(
                  isClaim ? 'Забрать опыт' : 'Задания',
                  style: TextStyle(color: isClaim ? AppColors.secondary100 : AppColors.white100, fontSize: 26.r, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26.r),
                ),
              ],
            ),
          ),
          if (isClaimed)
            Positioned(
              right: -16.r,
              top: -26.r,
              child: Image.asset(AppAssets.danger, width: 58.r, height: 58.r),
            ),
        ],
      ),
    );
  }
}
