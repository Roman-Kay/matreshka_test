import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/pause_menu_section.dart';

class PauseNavigationPanel extends StatelessWidget {
  const PauseNavigationPanel({super.key, required this.section});

  final PauseMenuSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 200.w, vertical: 100.h),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x46710808),
        borderRadius: BorderRadius.circular(42.r),
        border: Border.all(color: AppColors.white40, width: 1.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            section.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 54.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            section.placeholderText,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white70, fontSize: 28.sp),
          ),
        ],
      ),
    );
  }
}
