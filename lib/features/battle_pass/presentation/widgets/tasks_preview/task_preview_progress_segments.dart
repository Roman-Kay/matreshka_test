import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/theme/app_colors.dart';

class TaskPreviewProgressSegments extends StatelessWidget {
  const TaskPreviewProgressSegments({
    super.key,
    required this.count,
    required this.activeIndex,
  });

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
            decoration: BoxDecoration(
              color: index == activeIndex ? _activeColor : _inactiveColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          if (index != count - 1) SizedBox(width: divWidth),
        ],
      ],
    );
  }
}
