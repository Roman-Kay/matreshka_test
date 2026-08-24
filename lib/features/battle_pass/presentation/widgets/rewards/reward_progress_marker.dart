import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/theme/app_colors.dart';

class RewardProgressMarker extends StatelessWidget {
  const RewardProgressMarker({
    super.key,
    required this.level,
    required this.unlocked,
    required this.drawLeftLine,
    required this.drawRightLine,
  });

  final int level;
  final bool unlocked;
  final bool drawLeftLine;
  final bool drawRightLine;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFEF4029);
    const inactiveColor = AppColors.background10;
    final markerColor = unlocked ? activeColor : inactiveColor;
    return SizedBox(
      width: 242.w,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (drawLeftLine)
            Positioned(
              right: 121.w,
              width: 121.w,
              child: Container(height: 10.h, color: markerColor),
            ),
          if (drawRightLine)
            Positioned(
              left: 121.w,
              width: 121.w,
              child: Container(height: 10.h, color: markerColor),
            ),
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 45.r,
              height: 45.r,
              decoration: BoxDecoration(
                color: markerColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Text(
            '$level',
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.22,
            ),
          ),
        ],
      ),
    );
  }
}
