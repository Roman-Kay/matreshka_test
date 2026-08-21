import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';

class BattlePassLevelBadge extends StatelessWidget {
  const BattlePassLevelBadge({
    super.key,
    required this.progress,
    required this.premium,
  });

  final BattlePassProgress progress;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 130.w,
          height: 100.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.ratio,
                strokeWidth: 8.r,
                color: premium ? AppColors.gold : AppColors.white,
                backgroundColor: AppColors.white40,
              ),
              Text(
                '${progress.currentLevel}',
                style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Text(
          '${progress.currentXp} / ${progress.nextLevelXp}',
          style: TextStyle(fontSize: 22.sp, color: AppColors.white70),
        ),
      ],
    );
  }
}
