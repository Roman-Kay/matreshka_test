import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final canClaim = task.canClaim;
    final claimed = task.claimed;

    return Column(
      children: [
        Container(
          width: 394.w,
          height: 161.h,
          decoration: BoxDecoration(
            color: const Color(0xFF530202),
            borderRadius: BorderRadius.vertical(top: Radius.circular(60.r)),
          ),
          child: Row(
            children: [
              SizedBox(width: 33.w),
              Image.asset(task.rewardAssetPath, width: 131.r, height: 131.r),
              SizedBox(width: 23.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 166.w,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(color: const Color(0xFFF65231), borderRadius: BorderRadius.circular(30.r)),
                    child: Text(
                      task.rewardTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white100, fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'x ${task.rewardAmount}',
                    style: TextStyle(color: AppColors.white50, fontSize: 30.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.30),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 394.w,
          height: 341.h,
          decoration: BoxDecoration(
            color: const Color(0xFF7C1404),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(60.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 25.h),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${task.currentProgress} ',
                      style: const TextStyle(color: AppColors.secondary50),
                    ),
                    const TextSpan(
                      text: '/',
                      style: TextStyle(color: AppColors.white40),
                    ),
                    TextSpan(
                      text: ' ${task.requiredProgress}',
                      style: const TextStyle(color: AppColors.white100),
                    ),
                  ],
                  style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w600, height: 1.30, letterSpacing: -0.36),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 9.h),
              Container(width: 320.h, height: 2.h, color: AppColors.white10.withValues(alpha: 0.1)),
              SizedBox(height: 24.h),
              SizedBox(
                width: 322.w,
                child: Text(
                  task.title,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: TextStyle(color: claimed ? AppColors.white70 : AppColors.white80, fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10.w,
                children: [
                  _TaskActionButton(canClaim: canClaim, claimed: claimed),
                  const _TaskInfoButton(),
                ],
              ),
              SizedBox(height: 37.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  const _TaskActionButton({required this.canClaim, required this.claimed});

  final bool canClaim;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w,
      height: 88.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 1.00),
          end: Alignment(0.50, 0.00),
          colors: canClaim
              ? const [Color(0xFF55B675), Color(0xFF449761)]
              : claimed
              ? const [Color(0xFF9F4327), Color(0xFF9F4327)]
              : const [Color(0xFFE22929), Color(0xFFFF6435)],
        ),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(30.r), right: Radius.circular(6.r)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.w,
          children: [
            if (claimed) SvgPicture.asset(AppAssets.done, height: 30.r),
            Text(
              canClaim
                  ? 'Забрать опыт'
                  : claimed
                  ? 'Готово'
                  : 'Перейти',
              style: TextStyle(color: canClaim ? AppColors.secondary100 : AppColors.white100, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskInfoButton extends StatelessWidget {
  const _TaskInfoButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 88.h,
      decoration: BoxDecoration(
        color: const Color(0xFF530202),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(6.r), right: Radius.circular(30.r)),
      ),
      child: Center(
        child: SvgPicture.asset(AppAssets.question, height: 30.r, width: 30.r),
      ),
    );
  }
}
