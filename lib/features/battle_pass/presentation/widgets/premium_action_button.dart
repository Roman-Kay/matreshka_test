import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PremiumActionButton extends StatefulWidget {
  const PremiumActionButton({
    super.key,
    required this.iconAsset,
    required this.text,
    required this.onPressed,
  });

  final String iconAsset;
  final String text;
  final VoidCallback? onPressed;

  @override
  State<PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<PremiumActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 400.w,
        height: 100.h,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: const [
                    BoxShadow(color: Color(0xB2FF8900), blurRadius: 41.5),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEFCB4B), Color(0xFFDE7F28)],
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    return FractionalTranslation(
                      translation: Offset(_shineController.value * 2 - 1, 0),
                      child: child,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.42),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    widget.iconAsset,
                    width: 36.r,
                    height: 36.r,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF3B0B0B),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF3B0B0B),
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
