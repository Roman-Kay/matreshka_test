import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/painters/parallelogram_painter.dart';

class RewardAmountBadge extends StatelessWidget {
  const RewardAmountBadge({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 69.h,
      height: 36.h,
      child: CustomPaint(
        painter: ParallelogramPainter(fillColors: const [AppColors.dark, AppColors.dark, AppColors.dark], borderColor: AppColors.transparent, borderWidth: 0, skew: 8.h, radius: 10.h),
        child: Center(
          child: Text(
            'x$amount',
            style: TextStyle(color: AppColors.white100, fontSize: 26.h, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26.h),
          ),
        ),
      ),
    );
  }
}
