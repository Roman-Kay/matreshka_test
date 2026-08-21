import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';

class TasksPreview extends StatelessWidget {
  const TasksPreview({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Открыть задания',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(42.r),
        child: Container(
          width: 400.w,
          height: 400.h,
          padding: EdgeInsets.all(42.r),
          decoration: BoxDecoration(
            color: const Color(0x88380A16),
            borderRadius: BorderRadius.circular(42.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 64.r, color: AppColors.white),
              SizedBox(height: 24.h),
              Text(
                'Задания',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
