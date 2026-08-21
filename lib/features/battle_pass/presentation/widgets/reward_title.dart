import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';

class RewardTitle extends StatelessWidget {
  const RewardTitle({
    super.key,
    required this.reward,
    required this.premiumLocked,
  });

  final BattlePassReward? reward;
  final bool premiumLocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (premiumLocked)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.orange],
              ),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              'Доступно с прокачкой!',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        SizedBox(height: 10.h),
        Text(
          reward?.title ?? 'Мега пак',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
