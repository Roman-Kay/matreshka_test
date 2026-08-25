import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/pressable_scale.dart';
import '../../domain/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onClaim});

  final Task task;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final canClaim = task.canClaim;
    final claimed = task.claimed;

    return Column(
      children: [
        Container(
          width: 394.h,
          height: 161.h,
          decoration: BoxDecoration(
            color: const Color(0xFF530202),
            borderRadius: BorderRadius.vertical(top: Radius.circular(60.h)),
          ),
          child: Row(
            children: [
              SizedBox(width: 33.h),
              _TaskRewardImage(task: task),
              SizedBox(width: 23.h),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 166.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
                    decoration: BoxDecoration(color: const Color(0xFFF65231), borderRadius: BorderRadius.circular(30.h)),
                    child: Text(
                      task.rewardTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white100, fontSize: 22.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22.h),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'x ${task.rewardAmount}',
                    style: TextStyle(color: task.hasXpBonus ? const Color(0xFFFFD149) : AppColors.white50, fontSize: 30.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.30.h),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 394.h,
          height: 341.h,
          decoration: BoxDecoration(
            color: const Color(0xFF7C1404),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(60.h)),
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
                  style: TextStyle(fontSize: 36.h, fontWeight: FontWeight.w600, height: 1.30, letterSpacing: -0.36.h),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 9.h),
              Container(width: 320.h, height: 2.h, color: AppColors.white10.withValues(alpha: 0.1)),
              SizedBox(height: 24.h),
              SizedBox(
                width: 322.h,
                child: Text(
                  task.title,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: TextStyle(color: claimed ? AppColors.white70 : AppColors.white80, fontSize: 22.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22.h),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10.h,
                children: [
                  _TaskActionButton(canClaim: canClaim, claimed: claimed, onClaim: onClaim),
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

class _TaskRewardImage extends StatelessWidget {
  const _TaskRewardImage({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 131.h,
      height: 131.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Image.asset(task.rewardAssetPath, width: 131.h, height: 131.h),
          if (task.hasXpBonus)
            Positioned(
              bottom: 6.14.h,
              child: _TaskXpBonusBadge(percent: task.xpBonusPercent),
            ),
        ],
      ),
    );
  }
}

class _TaskXpBonusBadge extends StatelessWidget {
  const _TaskXpBonusBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94.h,
      height: 35.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment(0.50, 0), end: Alignment(0.50, 1), colors: [Color(0xFFEFCB4B), Color(0xFFF6733B)]),
        borderRadius: BorderRadius.circular(26.h),
      ),
      child: Center(
        child: Text(
          '+$percent%',
          textAlign: TextAlign.center,
          style: TextStyle(color: const Color(0xFF3C0B0B), fontSize: 5.63.h, fontWeight: FontWeight.w800, height: 1.20, letterSpacing: -0.06.h),
        ),
      ),
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  const _TaskActionButton({required this.canClaim, required this.claimed, this.onClaim});

  final bool canClaim;
  final bool claimed;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: !claimed,
      onTap: canClaim ? onClaim : null,
      child: Container(
        width: 250.h,
        height: 88.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, 1.00),
            end: Alignment(0.50, 0.00),
            colors: canClaim
                ? [Color(0xFF55B675).withValues(alpha: 0.4), Color(0xFF449761).withValues(alpha: 0.4)]
                : claimed
                ? const [Color(0xFF9F4327), Color(0xFF9F4327)]
                : const [Color(0xFFE22929), Color(0xFFFF6435)],
          ),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(30.h), right: Radius.circular(6.h)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.h,
            children: [
              if (claimed) SvgPicture.asset(AppAssets.done, height: 30.h),
              Text(
                canClaim
                    ? 'Забрать опыт'
                    : claimed
                    ? 'Готово'
                    : 'Перейти',
                style: TextStyle(color: canClaim ? AppColors.secondary100 : AppColors.white100, fontSize: 26.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26.h),
              ),
            ],
          ),
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
      width: 60.h,
      height: 88.h,
      decoration: BoxDecoration(
        color: const Color(0xFF530202),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(6.h), right: Radius.circular(30.h)),
      ),
      child: Center(
        child: SvgPicture.asset(AppAssets.question, height: 30.h, width: 30.h),
      ),
    );
  }
}
