import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';

@RoutePage()
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background10,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150.r,
                  height: 150.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E),
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: const [BoxShadow(color: Color(0x55E53E3E), blurRadius: 32, spreadRadius: 4)],
                  ),
                  child: Icon(Icons.sports_esports_rounded, color: AppColors.white100, size: 72.r),
                ),
                SizedBox(height: 50.h),
                Text(
                  'Тестовое задание для Матрешки РП\nот Романа\ntellegram: @RomanKaygo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white50, fontSize: 30.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.30.h),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 24.h,
            right: 100.w,
            child: _PauseButton(onPressed: () => context.router.push(const PauseShellRoute())),
          ),
        ],
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white5,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onPressed,
        child: SizedBox(
          width: 86.r,
          height: 86.r,
          child: Icon(Icons.pause_rounded, color: AppColors.white100, size: 48.r),
        ),
      ),
    );
  }
}
