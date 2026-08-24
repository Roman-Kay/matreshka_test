import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../battle_pass/domain/models/battle_pass_models.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final BattlePassTask task;

  @override
  Widget build(BuildContext context) {
    final canClaim = task.canClaim;
    final claimed = task.claimed;

    return SizedBox(
      width: 394.w,
      height: 502.h,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 161.h,
            child: Container(
              width: 394.w,
              height: 341.h,
              decoration: BoxDecoration(
                color: const Color(0xFF7C1404),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.r),
                  bottomRight: Radius.circular(60.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 394.w,
              height: 161.h,
              decoration: BoxDecoration(
                color: const Color(0xFF530202),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.r),
                  topRight: Radius.circular(60.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 33.w,
            top: 15.h,
            child: Image.asset(
              task.rewardAssetPath,
              width: 131.r,
              height: 131.r,
            ),
          ),
          Positioned(
            left: 187.w,
            top: 33.h,
            child: Container(
              width: 166.w,
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF65231),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                task.rewardTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white100,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.22,
                ),
              ),
            ),
          ),
          Positioned(
            left: 187.w,
            top: 91.h,
            child: SizedBox(
              width: 139.w,
              height: 40.h,
              child: Text(
                'x ${task.rewardAmount}',
                style: TextStyle(
                  color: const Color(0x7FE9E9F3),
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ),
          Positioned(
            top: 186.h,
            left: 0,
            right: 0,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${task.currentProgress}',
                    style: const TextStyle(color: AppColors.secondary50),
                  ),
                  const TextSpan(
                    text: ' ',
                    style: TextStyle(color: AppColors.white60),
                  ),
                  const TextSpan(
                    text: '/ ',
                    style: TextStyle(color: AppColors.white40),
                  ),
                  TextSpan(
                    text: '${task.requiredProgress}',
                    style: const TextStyle(color: AppColors.white100),
                  ),
                ],
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.30,
                  letterSpacing: -0.36,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 37.w,
            top: 268.h,
            child: SizedBox(
              width: 322.w,
              child: Text(
                task.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xCCE9E9F3),
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.22,
                ),
              ),
            ),
          ),
          Positioned(
            left: 37.w,
            top: 377.h,
            child: _TaskActionButton(canClaim: canClaim, claimed: claimed),
          ),
          Positioned(left: 297.w, top: 377.h, child: const _TaskInfoButton()),
        ],
      ),
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
      height: canClaim ? null : 90.h,
      padding: canClaim ? EdgeInsets.fromLTRB(36.w, 20.h, 36.w, 23.h) : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: canClaim
              ? const [Color(0xFF55B675), Color(0xFF449761)]
              : claimed
              ? const [Color(0xFF9E431F), Color(0xFFB95835)]
              : const [Color(0xFFE22929), Color(0xFFFF6435)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(6.r),
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(6.r),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.w,
          children: [
            if (claimed)
              Icon(
                Icons.check_rounded,
                size: 24.r,
                color: AppColors.secondary50,
              ),
            Text(
              canClaim
                  ? 'Забрать опыт'
                  : claimed
                  ? 'Готово'
                  : 'Перейти',
              style: TextStyle(
                color: canClaim ? const Color(0xFF68C286) : AppColors.white100,
                fontSize: 26.sp,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.26,
              ),
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
      height: 90.h,
      decoration: BoxDecoration(
        color: const Color(0xFF530202),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          topRight: Radius.circular(30.r),
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: AppColors.white40,
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}
