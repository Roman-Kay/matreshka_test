import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF530202), Color(0xFFFF5A13)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 32.w,
                top: 32.h,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Назад',
                ),
              ),
              Positioned(
                top: 46.h,
                left: 120.w,
                child: Text(
                  'Задания боевого пропуска',
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              Positioned.fill(
                top: 150.h,
                child: ListView.separated(
                  padding: EdgeInsets.all(32.r),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => _TaskCard(index: index),
                  separatorBuilder: (context, index) => SizedBox(width: 28.w),
                  itemCount: 5,
                ),
              ),
              Positioned(
                left: 160.w,
                bottom: 32.h,
                child: Text(
                  'На 25% быстрее с прокачкой!',
                  style: TextStyle(fontSize: 30.sp, color: AppColors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final done = index == 2;
    return Container(
      width: 300.w,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(42.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt, size: 48.r, color: AppColors.gold),
          SizedBox(height: 12.h),
          Text(
            done ? '10 / 10' : '1 / 3',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Используйте определенный предмет 10 раз в классическом режиме.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {},
            child: Text(done ? 'Готово' : 'Перейти'),
          ),
        ],
      ),
    );
  }
}
