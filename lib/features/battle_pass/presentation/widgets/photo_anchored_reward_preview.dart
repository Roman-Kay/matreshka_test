import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/models/battle_pass_models.dart';
import 'rewards/reward_title.dart';

class PhotoAnchoredRewardPreview extends StatefulWidget {
  const PhotoAnchoredRewardPreview({
    super.key,
    required this.designSize,
    required this.designCenter,
    required this.designSizePx,
    required this.reward,
    required this.choiceRewards,
    required this.premiumLocked,
  });

  final Size designSize;
  final Offset designCenter;
  final double designSizePx;
  final BattlePassReward? reward;
  final List<BattlePassReward> choiceRewards;
  final bool premiumLocked;

  @override
  State<PhotoAnchoredRewardPreview> createState() =>
      _PhotoAnchoredRewardPreviewState();
}

class _PhotoAnchoredRewardPreviewState extends State<PhotoAnchoredRewardPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final contentLeft = screenSize.width - constraints.maxWidth;
        final scale = _coverScale(widget.designSize, screenSize);
        final backgroundLeft =
            (screenSize.width - widget.designSize.width * scale) / 2;
        final backgroundTop =
            (screenSize.height - widget.designSize.height * scale) / 2;
        final center = Offset(
          backgroundLeft + widget.designCenter.dx * scale - contentLeft,
          backgroundTop + widget.designCenter.dy * scale,
        );
        final previewSize = widget.designSizePx.w;
        final titleWidth = previewSize * 1.55;

        return Stack(
          children: [
            Positioned(
              left: center.dx - titleWidth / 2,
              top: center.dy - previewSize / 2,
              width: titleWidth,
              child: Column(
                children: [
                  SizedBox(
                    width: titleWidth,
                    child: Center(
                      child: _AnimatedRewardPreviewImage(
                        animation: _idleController,
                        assetPath: widget.reward?.assetPath ?? AppAssets.hero,
                        size: previewSize,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -13.h),
                    child: RewardTitle(
                      reward: widget.reward,
                      choiceRewards: widget.choiceRewards,
                      premiumLocked: widget.premiumLocked,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _coverScale(Size designSize, Size viewport) {
    if (viewport.isEmpty) return 1;
    return (viewport.width / designSize.width).clamp(
      viewport.height / designSize.height,
      double.infinity,
    );
  }
}

class _AnimatedRewardPreviewImage extends StatelessWidget {
  const _AnimatedRewardPreviewImage({
    required this.animation,
    required this.assetPath,
    required this.size,
  });

  final Animation<double> animation;
  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        child: Image.asset(assetPath, width: size, height: size),
        builder: (context, child) {
          final eased = Curves.easeInOutSine.transform(animation.value);
          final floatY = (eased - 0.5) * 10.h;
          final scale = 1 + (eased - 0.5) * 0.018;

          return Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(scale: scale, child: child),
          );
        },
      ),
    );
  }
}
