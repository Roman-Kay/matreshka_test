import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pressable_scale.dart';

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
  late final AnimationController _animationController;
  late final Animation<double> _shadowPulse;
  late final Animation<Offset> _shinePosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();

    _shadowPulse = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 65,
      ),
    ]).animate(_animationController);

    _shinePosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.20, -0.85),
          end: const Offset(0.04, 0.02),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.04, 0.02),
          end: const Offset(-0.10, -0.08),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.10, -0.08),
          end: const Offset(1.20, 0.85),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 41,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: widget.onPressed,
      enabled: widget.onPressed != null,
      child: SizedBox(
        width: 400.r,
        height: 100.r,
        child: AnimatedBuilder(
          animation: _animationController,
          child: _PremiumActionButtonLabel(
            iconAsset: widget.iconAsset,
            text: widget.text,
          ),
          builder: (context, child) {
            final pulse = _shadowPulse.value;

            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0x99FF8900),
                            const Color(0xFFFFB02E),
                            pulse,
                          )!,
                          blurRadius: (34 + 20 * pulse).r,
                          spreadRadius: (1 + 4 * pulse).r,
                        ),
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
                    child: FractionalTranslation(
                      translation: _shinePosition.value,
                      child: const _PremiumActionButtonShine(),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumActionButtonShine extends StatelessWidget {
  const _PremiumActionButtonShine();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 150.r,
          top: -28.r,
          child: _PremiumActionButtonShineLine(
            width: 92.r,
            height: 165.r,
            opacity: 0.15,
          ),
        ),
        Positioned(
          left: 238.r,
          top: -16.r,
          child: _PremiumActionButtonShineLine(
            width: 34.r,
            height: 136.r,
            opacity: 0.10,
          ),
        ),
      ],
    );
  }
}

class _PremiumActionButtonShineLine extends StatelessWidget {
  const _PremiumActionButtonShineLine({
    required this.width,
    required this.height,
    required this.opacity,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.56,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: opacity),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0, 0.52, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumActionButtonLabel extends StatelessWidget {
  const _PremiumActionButtonLabel({
    required this.iconAsset,
    required this.text,
  });

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 36.r,
            height: 36.r,
            colorFilter: const ColorFilter.mode(
              Color(0xFF3B0B0B),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 24.r),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF3B0B0B),
                fontSize: 30.r,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.30.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
