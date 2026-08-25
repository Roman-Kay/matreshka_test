import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/painters/parallelogram_painter.dart';
import '../../../domain/models/battle_pass_models.dart';
import 'reward_amount_badge.dart';
import 'reward_rarity_style.dart';

class RewardDetailsSheet extends StatelessWidget {
  const RewardDetailsSheet({
    super.key,
    required this.reward,
    required this.choiceRewards,
    required this.level,
    required this.premiumStatus,
    required this.onClaim,
  });

  final BattlePassReward reward;
  final List<BattlePassReward> choiceRewards;
  final int level;
  final PremiumStatus premiumStatus;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final premiumLocked =
        reward.track == BattlePassTrack.premium &&
        premiumStatus == PremiumStatus.locked;
    final canClaim = reward.status == RewardStatus.available && !premiumLocked;
    final actionText = premiumLocked
        ? 'Прокачать'
        : reward.status == RewardStatus.received
        ? 'Получено'
        : reward.status == RewardStatus.available
        ? 'Забрать'
        : 'Заблокировано';

    return Padding(
      padding: EdgeInsets.fromLTRB(28.h, 24.h, 28.h, 28.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 240.h,
            height: 190.h,
            child: CustomPaint(
              painter: ParallelogramPainter(
                fillColors: reward.rarity.gradientColors,
                borderColor: reward.rarity.accentColor,
                borderWidth: 2.h,
                skew: 24.h,
                radius: 24.h,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.h),
                      child: Image.asset(
                        reward.assetPath ?? AppAssets.railBirthdayMask,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (reward.amount > 1)
                    Positioned(
                      right: 20.h,
                      bottom: 14.h,
                      child: RewardAmountBadge(amount: reward.amount),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 28.h),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SheetPill(text: 'Уровень $level'),
                    SizedBox(width: 10.h),
                    _SheetPill(
                      text: reward.track.label,
                      color: reward.track == BattlePassTrack.premium
                          ? AppColors.gold
                          : AppColors.green,
                      textColor: AppColors.ink,
                    ),
                    if (level % 10 == 0) ...[
                      SizedBox(width: 10.h),
                      const _SheetPill(
                        text: 'Большой приз',
                        color: AppColors.orange,
                        textColor: AppColors.ink,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 14.h),
                if (choiceRewards.length > 1)
                  _ChoiceRewardTitle(rewards: choiceRewards)
                else
                  Text(
                    reward.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white100,
                      fontSize: 30.h,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                if (choiceRewards.length > 1) ...[
                  SizedBox(height: 18.h),
                  Wrap(
                    spacing: 14.h,
                    runSpacing: 14.h,
                    children: [
                      for (final choiceReward in choiceRewards)
                        _ChoiceRewardCard(reward: choiceReward),
                    ],
                  ),
                ],
                SizedBox(height: 12.h),
                Text(
                  _statusText(premiumLocked),
                  style: TextStyle(
                    color: premiumLocked ? AppColors.gold : AppColors.white70,
                    fontSize: 20.h,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: 230.h,
                  height: 58.h,
                  child: ElevatedButton(
                    onPressed: canClaim
                        ? () {
                            onClaim();
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: premiumLocked
                          ? AppColors.gold
                          : AppColors.green,
                      disabledBackgroundColor: AppColors.background10,
                      foregroundColor: AppColors.ink,
                      disabledForegroundColor: AppColors.white40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.h),
                      ),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 22.h,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(bool premiumLocked) {
    if (premiumLocked) return 'Награда доступна только с премиум-прокачкой.';
    return switch (reward.status) {
      RewardStatus.received => 'Эта награда уже получена.',
      RewardStatus.available => 'Награда доступна. Можно забрать сейчас.',
      RewardStatus.locked => 'Откроется после достижения нужного уровня.',
    };
  }
}

class _ChoiceRewardTitle extends StatelessWidget {
  const _ChoiceRewardTitle({required this.rewards});

  final List<BattlePassReward> rewards;

  @override
  Widget build(BuildContext context) {
    final firstTitle = rewards.first.title;
    final secondTitle = rewards.length > 1 ? rewards[1].title : '';
    final titleStyle = TextStyle(
      color: AppColors.white100,
      fontSize: 36.h,
      fontWeight: FontWeight.w600,
      height: 1.30,
      letterSpacing: -0.36.h,
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.h,
        children: [
          Text(firstTitle, textAlign: TextAlign.center, style: titleStyle),
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
          Text(secondTitle, textAlign: TextAlign.center, style: titleStyle),
        ],
      ),
    );
  }
}

class _ChoiceRewardCard extends StatelessWidget {
  const _ChoiceRewardCard({required this.reward});

  final BattlePassReward reward;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132.h,
      height: 108.h,
      child: CustomPaint(
        painter: ParallelogramPainter(
          fillColors: reward.rarity.gradientColors,
          borderColor: reward.rarity.accentColor,
          borderWidth: 2.h,
          skew: 16.h,
          radius: 18.h,
        ),
        child: Padding(
          padding: EdgeInsets.all(14.h),
          child: Image.asset(
            reward.assetPath ?? AppAssets.railBirthdayMask,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _SheetPill extends StatelessWidget {
  const _SheetPill({
    required this.text,
    this.color = AppColors.white10,
    this.textColor = AppColors.white100,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14.h,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

extension _BattlePassTrackLabel on BattlePassTrack {
  String get label {
    return switch (this) {
      BattlePassTrack.free => 'Бесплатная',
      BattlePassTrack.premium => 'Премиум',
    };
  }
}
