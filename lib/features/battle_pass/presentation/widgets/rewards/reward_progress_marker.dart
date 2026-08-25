import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/theme/app_colors.dart';

class RewardProgressMarker extends StatelessWidget {
  const RewardProgressMarker({super.key, required this.level, required this.unlocked, required this.drawLeftLine, required this.drawRightLine});

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
      width: 242.h,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (drawLeftLine)
            Positioned(
              right: 121.h,
              width: 121.h,
              child: Container(height: 10.h, color: markerColor),
            ),
          if (drawRightLine)
            Positioned(
              left: 121.h,
              width: 121.h,
              child: Container(height: 10.h, color: markerColor),
            ),
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 45.h,
              height: 45.h,
              decoration: BoxDecoration(color: markerColor, borderRadius: BorderRadius.circular(8.h)),
            ),
          ),
          Text(
            '$level',
            style: TextStyle(color: AppColors.white100, fontSize: 22.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22.h),
          ),
        ],
      ),
    );
  }
}
