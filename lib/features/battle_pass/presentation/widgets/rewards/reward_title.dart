import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';
import 'package:romankaygo_test_rp/core/theme/app_colors.dart';
import '../../../domain/models/battle_pass_models.dart';

class RewardTitle extends StatelessWidget {
  const RewardTitle({
    super.key,
    required this.reward,
    required this.choiceRewards,
    required this.premiumLocked,
  });

  final BattlePassReward? reward;
  final List<BattlePassReward> choiceRewards;
  final bool premiumLocked;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: AppColors.white100,
      fontSize: 36.h,
      fontWeight: FontWeight.w600,
      height: 1.30,
      letterSpacing: -0.36.h,
    );
    final showPremiumBadge =
        premiumLocked && reward?.track == BattlePassTrack.premium;

    return Column(
      children: [
        if (showPremiumBadge)
          Container(
            height: 39.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.50, -0.00),
                end: Alignment(0.50, 1.00),
                colors: [Color(0xFFEFCB4B), Color(0xFFF6733B)],
              ),
              borderRadius: BorderRadius.circular(30.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 12.h),
                SvgPicture.asset(AppAssets.premium, width: 24.h, height: 24.h),
                SizedBox(width: 12.h),
                Text(
                  'Доступно с прокачкой!',
                  style: TextStyle(
                    color: const Color(0xFF3C0B0B),
                    fontSize: 22.h,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.22.h,
                  ),
                ),
                SizedBox(width: 19.h),
              ],
            ),
          )
        else
          SizedBox(height: 39.h),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            choiceRewards.length > 1
                ? _ChoiceRewardTitle(
                    rewards: choiceRewards,
                    titleStyle: titleStyle,
                  )
                : Text(
                    reward?.title ?? 'Мега пак',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
            SizedBox(width: 16.h),
            SvgPicture.asset(AppAssets.info, width: 36.h, height: 36.h),
          ],
        ),
      ],
    );
  }
}

class _ChoiceRewardTitle extends StatelessWidget {
  const _ChoiceRewardTitle({required this.rewards, required this.titleStyle});

  final List<BattlePassReward> rewards;
  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.h,
      children: [
        Text(
          rewards.first.title,
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFCB4C), Color(0xFFDE8029)],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            'или',
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(color: AppColors.white100),
          ),
        ),
        Text(rewards[1].title, textAlign: TextAlign.center, style: titleStyle),
      ],
    );
  }
}
