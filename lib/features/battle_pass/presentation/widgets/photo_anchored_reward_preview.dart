import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/models/battle_pass_models.dart';
import 'rewards/reward_title.dart';

class PhotoAnchoredRewardPreview extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final contentLeft = screenSize.width - constraints.maxWidth;
        final scale = _coverScale(screenSize);
        final backgroundLeft =
            (screenSize.width - designSize.width * scale) / 2;
        final backgroundTop =
            (screenSize.height - designSize.height * scale) / 2;
        final center = Offset(
          backgroundLeft + designCenter.dx * scale - contentLeft,
          backgroundTop + designCenter.dy * scale,
        );
        final previewSize = designSizePx.w;
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
                      child: Image.asset(
                        reward?.assetPath ?? AppAssets.hero,
                        width: previewSize,
                        height: previewSize,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -13.h),
                    child: RewardTitle(
                      reward: reward,
                      choiceRewards: choiceRewards,
                      premiumLocked: premiumLocked,
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

  double _coverScale(Size viewport) {
    if (viewport.isEmpty) return 1;
    return (viewport.width / designSize.width).clamp(
      viewport.height / designSize.height,
      double.infinity,
    );
  }
}
