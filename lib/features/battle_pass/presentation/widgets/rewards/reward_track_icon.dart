import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../domain/models/battle_pass_models.dart';

class RewardTrackIcon extends StatelessWidget {
  const RewardTrackIcon({super.key, required this.track});

  final BattlePassTrack track;

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (track) {
      BattlePassTrack.free => AppAssets.freeReward,
      BattlePassTrack.premium => AppAssets.premiumReward,
    };
    return Image.asset(assetPath, width: 55.r, height: 50.r);
  }
}
