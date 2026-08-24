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
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF16191F), Color(0xFF07080B)],
              ),
            ),
          ),
          CustomPaint(painter: _GameGridPainter()),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 24.h,
            right: 36.w,
            child: _PauseButton(
              onPressed: () => context.router.push(const PauseMenuRoute()),
            ),
          ),
          Center(
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55E53E3E),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.sports_esports_rounded,
                color: AppColors.white100,
                size: 72.r,
              ),
            ),
          ),
          Positioned(
            left: 42.w,
            bottom: 38.h,
            child: Text(
              'Game screen',
              style: TextStyle(
                color: AppColors.white40,
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          child: Icon(
            Icons.pause_rounded,
            color: AppColors.white100,
            size: 48.r,
          ),
        ),
      ),
    );
  }
}

class _GameGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white5
      ..strokeWidth = 1;
    const step = 72.0;

    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
