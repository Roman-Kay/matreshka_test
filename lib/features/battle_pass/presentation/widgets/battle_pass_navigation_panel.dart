import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';

class BattlePassNavigationPanel extends StatelessWidget {
  const BattlePassNavigationPanel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 346.w,
      right: 120.w,
      top: 170.h,
      bottom: 120.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x88380A16),
          borderRadius: BorderRadius.circular(42.r),
          border: Border.all(color: AppColors.white40, width: 1.r),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 54.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Панель открыта',
                style: TextStyle(color: AppColors.white70, fontSize: 28.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
