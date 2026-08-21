import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';

class PremiumPanel extends StatelessWidget {
  const PremiumPanel({super.key, required this.pass});

  final BattlePass pass;

  @override
  Widget build(BuildContext context) {
    final maxed = pass.progress.currentLevel >= pass.season.maxLevel;
    return SizedBox(
      width: 470.w,
      child: Column(
        children: [
          Text(
            'Повышение уровня',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36.sp,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Повышай уровень боевого пропуска и забирай новые награды!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, color: AppColors.white70),
          ),
          SizedBox(height: 26.h),
          FilledButton(
            onPressed: maxed
                ? null
                : () => context.read<BattlePassCubit>().purchasePremium(),
            style: FilledButton.styleFrom(
              fixedSize: Size(400.w, 100.h),
              backgroundColor: pass.premiumStatus == PremiumStatus.purchased
                  ? AppColors.green
                  : AppColors.gold,
              foregroundColor: AppColors.ink,
            ),
            child: Text(
              maxed
                  ? 'Достигнут максимальный уровень'
                  : pass.premiumStatus == PremiumStatus.purchased
                  ? 'Забрать все награды'
                  : 'Прокачать',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
