import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../tasks/domain/models/task.dart';

class TaskPreviewHeader extends StatelessWidget {
  const TaskPreviewHeader({
    super.key,
    required this.task,
    required this.taskIndex,
    required this.taskCount,
  });

  final Task task;
  final int taskIndex;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final opacity = task.claimed ? 0.4 : 1.0;

    return Center(
      child: SizedBox(
        width: 320.r,
        child: Row(
          children: [
            Opacity(
              opacity: opacity,
              child: Image.asset(
                task.rewardAssetPath,
                width: 96.r,
                height: 96.r,
              ),
            ),
            SizedBox(width: 12.r),
            Opacity(
              opacity: opacity,
              child: Text(
                'x ${task.rewardAmount}',
                style: TextStyle(
                  color: AppColors.white100,
                  fontSize: 26.r,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.26.r,
                ),
              ),
            ),
            const Spacer(),
            if (task.claimed)
              Container(
                width: 132.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.background5,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 42.r,
                    color: const Color(0xFF2DDB72),
                  ),
                ),
              )
            else
              Container(
                width: 112.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.background5,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${taskIndex + 1}',
                          style: TextStyle(
                            color: AppColors.secondary50,
                            fontSize: 26.r,
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                            letterSpacing: -0.26.r,
                          ),
                        ),
                        TextSpan(
                          text: ' / $taskCount',
                          style: TextStyle(
                            color: AppColors.white40,
                            fontSize: 26.r,
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                            letterSpacing: -0.26.r,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
