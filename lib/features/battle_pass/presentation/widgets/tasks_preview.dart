import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';

import '../../../../core/theme/app_colors.dart';

class TasksPreview extends StatelessWidget {
  const TasksPreview({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 61.w),
      child: SizedBox(
        width: 400.w,
        child: Column(
          children: [
            Container(
              height: 110.h,
              decoration: BoxDecoration(
                color: const Color(0xFF353747).withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Center(
                child: SizedBox(
                  width: 320.w,
                  child: Row(
                    children: [
                      Image.asset(AppAssets.xp, width: 96.r, height: 96.r),
                      SizedBox(width: 12.w),
                      Text(
                        'x 25',
                        style: TextStyle(color: AppColors.white100, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
                      ),
                      const Spacer(),
                      Container(
                        width: 112.w,
                        height: 56.h,
                        decoration: BoxDecoration(color: AppColors.background5, borderRadius: BorderRadius.circular(20.r)),
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '3',
                                  style: TextStyle(color: AppColors.secondary50, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
                                ),

                                TextSpan(
                                  text: ' / 5',
                                  style: TextStyle(color: AppColors.white40, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 290.h,
              decoration: BoxDecoration(
                color: const Color(0xFF202231).withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Spacer(flex: 44),
                  SizedBox(
                    width: 320.w,
                    child: Text(
                      'Используйте определенный предмет (Энергетик) 10 раз.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white60, fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
                    ),
                  ),
                  const Spacer(flex: 50),
                  const _ProgressSegments(count: 4, activeIndex: 0),
                  SizedBox(height: 26.h),
                  GestureDetector(
                    onTap: () {
                      // Handle tap event
                    },
                    child: Container(
                      width: 320.w,
                      height: 74.h,
                      decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(30.r)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 16.w,
                        children: [
                          SvgPicture.asset(AppAssets.tasks, width: 30.r, height: 30.r),
                          Text(
                            'Задания',
                            style: TextStyle(color: AppColors.white100, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  static const _activeColor = AppColors.white60;
  static const _inactiveColor = AppColors.white10;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final divWidth = 12.w;
    final totalWidth = divWidth * (count - 1);
    final segmentWidth = (320.w - totalWidth) / count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++) ...[
          Container(
            width: segmentWidth,
            height: 8.h,
            decoration: BoxDecoration(color: index == activeIndex ? _activeColor : _inactiveColor, borderRadius: BorderRadius.circular(4.r)),
          ),
          if (index != count - 1) SizedBox(width: divWidth),
        ],
      ],
    );
  }
}
