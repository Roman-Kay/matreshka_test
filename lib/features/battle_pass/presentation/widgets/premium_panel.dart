import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/buttons/premium_action_button.dart';
import '../../domain/models/battle_pass_models.dart';

class PremiumPanel extends StatelessWidget {
  const PremiumPanel({
    super.key,
    required this.pass,
    required this.onPurchasePremium,
    required this.onClaimAllRewards,
  });

  final BattlePass pass;
  final VoidCallback onPurchasePremium;
  final VoidCallback onClaimAllRewards;

  @override
  Widget build(BuildContext context) {
    final maxed = pass.progress.currentLevel >= pass.season.maxLevel;
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final availableRewardsCount = _availableRewardsCount(pass);
    if (premiumLocked) {
      return _ElitePassPanel(onPurchasePremium: onPurchasePremium);
    }

    return _LevelUpPanel(
      maxed: maxed,
      canClaimAll: maxed && availableRewardsCount > 3,
      onClaimAll: onClaimAllRewards,
      onLevelUp: onPurchasePremium,
    );
  }

  int _availableRewardsCount(BattlePass pass) {
    var count = 0;
    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        if (reward.status == RewardStatus.available) count += 1;
      }
    }
    return count;
  }
}

class _LevelUpPanel extends StatelessWidget {
  const _LevelUpPanel({
    required this.maxed,
    required this.canClaimAll,
    required this.onClaimAll,
    required this.onLevelUp,
  });

  final bool maxed;
  final bool canClaimAll;
  final VoidCallback onClaimAll;
  final VoidCallback onLevelUp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(AppAssets.levelUp, width: 605.r, height: 690.r),
        Positioned(
          top: 367.r,
          right: 80.r,
          child: Column(
            children: [
              Text(
                'Повышение уровня',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFFD149),
                  fontSize: 36.r,
                  fontWeight: FontWeight.w600,
                  height: 1.30,
                  letterSpacing: -0.36.r,
                ),
              ),
              SizedBox(height: 1.r),
              SizedBox(
                width: 400.r,
                child: Text(
                  'Повышай уровень боевого пропуска и забирай новые награды!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white70,
                    fontSize: 22.r,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.22.r,
                  ),
                ),
              ),
              SizedBox(height: maxed ? 27.r : 53.r),
              if (maxed) ...[
                const _MaxLevelButton(),
                if (canClaimAll) ...[
                  SizedBox(height: 24.r),
                  _ClaimAllRewardsButton(onPressed: onClaimAll),
                ],
              ] else if (canClaimAll)
                _ClaimAllRewardsButton(onPressed: onClaimAll)
              else
                PremiumActionButton(
                  iconAsset: AppAssets.arrowLevelUp,
                  text: 'Повысить уровень',
                  onPressed: onLevelUp,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ElitePassPanel extends StatelessWidget {
  const _ElitePassPanel({required this.onPurchasePremium});

  final VoidCallback onPurchasePremium;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 570.r,
      height: 660.r,
      child: Stack(
        children: [
          Image.asset(
            AppAssets.woman,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          Positioned(
            top: 370.r,
            right: 70.r,
            child: Column(
              children: [
                Text(
                  'Элитный пропуск',
                  style: TextStyle(
                    color: const Color(0xFFFFD149),
                    fontSize: 36.r,
                    fontWeight: FontWeight.w600,
                    height: 1.30,
                    letterSpacing: -0.36.r,
                  ),
                ),
                SizedBox(height: 1.r),
                SizedBox(
                  width: 400.r,
                  child: Text(
                    'Прокачай боевой пропуск и забери четкие скины, аксессуары и многое другое!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white70,
                      fontSize: 22.r,
                      fontWeight: FontWeight.w500,
                      height: 1.20,
                      letterSpacing: -0.22.r,
                    ),
                  ),
                ),
                SizedBox(height: 27.r),
                PremiumActionButton(
                  iconAsset: AppAssets.premium,
                  text: 'Прокачать',
                  onPressed: onPurchasePremium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxLevelButton extends StatelessWidget {
  const _MaxLevelButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.r,
      height: 100.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x19E9E9F3),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(48.r, 30.r, 48.r, 34.r),
          child: Center(
            child: Text(
              'Достигнут максимальный уровень',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0x66E9E9F3),
                fontSize: 22.r,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.22.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClaimAllRewardsButton extends StatelessWidget {
  const _ClaimAllRewardsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 400.r,
        padding: EdgeInsets.fromLTRB(36.r, 20.r, 36.r, 23.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF56B876), Color(0xFF44955F)],
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Забрать все награды',
              style: TextStyle(
                color: AppColors.white100,
                fontSize: 26.r,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.26.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
