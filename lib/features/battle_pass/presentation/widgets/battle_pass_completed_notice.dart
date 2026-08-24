import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class BattlePassCompletedNotice extends StatelessWidget {
  const BattlePassCompletedNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 51.w, top: 110.h),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 52.h),
            child: Container(
              padding: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 32.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: GradientBoxBorder(
                  width: 4.r,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA34E), Color(0xFFFFC847), Color(0xFFFFE383), Color(0xFFFFB51B), Color(0xFFFF7B5F)],
                  ),
                ),
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: [BoxShadow(color: const Color(0x51FFB800), blurRadius: 100.r)],
              ),
              child: Column(
                children: [
                  Text(
                    'Battle Pass завершен',
                    style: TextStyle(color: AppColors.white, fontSize: 36.sp, fontWeight: FontWeight.w600, height: 1.30, letterSpacing: -0.36),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: 386.w,
                    child: Text(
                      'Успей забрать оставшиеся награды!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white40, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  const _CompletedTimerPill(),
                ],
              ),
            ),
          ),
          Image.asset(AppAssets.danger, height: 110.h),
        ],
      ),
    );
  }
}

class _CompletedTimerPill extends StatefulWidget {
  const _CompletedTimerPill();

  @override
  State<_CompletedTimerPill> createState() => _CompletedTimerPillState();
}

class _CompletedTimerPillState extends State<_CompletedTimerPill> with TickerProviderStateMixin {
  static const _figmaEase = Cubic(0, 0, 0.58, 1);

  late final AnimationController _settleController;
  late final Animation<double> _settleOffset;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..forward();
    _settleOffset = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _settleController, curve: _figmaEase));
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settleOffset,
      builder: (context, child) {
        return Transform.translate(offset: Offset(-90.w * _settleOffset.value, 90.h * _settleOffset.value), child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.00, -0.00),
            end: Alignment(1.00, 1.00),
            colors: [const Color(0xFFFFA24D), const Color(0xFFFFC847), const Color(0xFFFFB51B), const Color(0xFFFF7B5E)],
          ),
          borderRadius: BorderRadius.circular(60.r),
        ),
        child: Text(
          '6д 13ч 55м',
          style: TextStyle(color: AppColors.dark100, fontSize: 30.sp, fontWeight: FontWeight.w600, height: 1.20, letterSpacing: -0.30),
        ),
      ),
    );
  }
}
