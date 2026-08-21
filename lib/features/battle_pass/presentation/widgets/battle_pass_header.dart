import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';
import 'level_badge.dart';

class BattlePassHeader extends StatelessWidget {
  const BattlePassHeader({super.key, required this.pass});

  final BattlePass pass;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 346.w,
      top: 37.h,
      child: GestureDetector(
        onLongPress: () => _showDemoSheet(context),
        child: Row(
          children: [
            BattlePassLevelBadge(
              progress: pass.progress,
              premium: pass.premiumStatus == PremiumStatus.purchased,
            ),
            SizedBox(width: 36.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '15д 12ч 42м',
                  style: TextStyle(fontSize: 26.sp, color: AppColors.white40),
                ),
                Text(
                  pass.season.title,
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ink,
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: BattlePassDemoMode.values
              .map((mode) {
                return ListTile(
                  title: Text(switch (mode) {
                    BattlePassDemoMode.premiumLocked => 'Премиум не приобретен',
                    BattlePassDemoMode.premiumUnlocked => 'Премиум приобретен',
                    BattlePassDemoMode.maxLevel => 'Максимальный уровень',
                  }),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<BattlePassCubit>().switchDemoMode(mode);
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
