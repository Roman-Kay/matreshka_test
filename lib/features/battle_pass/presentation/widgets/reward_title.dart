import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';
import 'package:romankaygo_test_rp/core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';

class RewardTitle extends StatelessWidget {
  const RewardTitle({super.key, required this.reward, required this.premiumLocked});

  final BattlePassReward? reward;
  final bool premiumLocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (premiumLocked)
          Container(
            height: 39.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment(0.50, -0.00), end: Alignment(0.50, 1.00), colors: [const Color(0xFFEFCB4B), const Color(0xFFF6733B)]),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 12.w),
                SvgPicture.asset(AppAssets.premium, width: 24.r, height: 24.r),
                SizedBox(width: 12.w),
                Text(
                  'Доступно с прокачкой!',
                  style: TextStyle(color: const Color(0xFF3C0B0B), fontSize: 22.sp, fontFamily: 'Geologica Roman', fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
                ),
                SizedBox(width: 19.w),
              ],
            ),
          ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              reward?.title ?? 'Мега пак',
              style: TextStyle(color: AppColors.white100, fontSize: 36.sp, fontWeight: FontWeight.w600, height: 1.30, letterSpacing: -0.36),
            ),
            SizedBox(width: 16.w),
            SvgPicture.asset(AppAssets.info, width: 36.r, height: 36.r),
          ],
        ),
      ],
    );
  }
}
