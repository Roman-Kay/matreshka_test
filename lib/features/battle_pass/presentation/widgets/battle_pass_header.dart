import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';
import 'package:romankaygo_test_rp/core/ui/buttons/header_icon_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import 'level_badge.dart';

class BattlePassHeader extends StatelessWidget {
  const BattlePassHeader({
    super.key,
    required this.pass,
    required this.onDemoModeSelected,
    this.onClose,
  });

  final BattlePass pass;
  final ValueChanged<BattlePassDemoMode> onDemoModeSelected;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDemoSheet(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 51.w),
        child: Row(
          children: [
            BattlePassLevelBadge(progress: pass.progress),
            SizedBox(width: 37.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.clock,
                      width: 32.w,
                      height: 32.h,
                    ),
                    SizedBox(width: 14.w),
                    Text(
                      '15д 12ч 42м',
                      style: TextStyle(
                        color: AppColors.white40,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                        letterSpacing: -0.26,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEF6429), Color(0xFFD63A26)],
                    ).createShader(bounds);
                  },
                  child: Text(
                    pass.season.title,
                    style: TextStyle(
                      fontSize: 48.sp,
                      color: Color(0xFFD63A26),
                      fontWeight: FontWeight.w600,
                      height: 0.93,
                      letterSpacing: -0.48.w,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (onClose != null)
              HeaderIconButton(assetPath: AppAssets.close, onTap: onClose!),
          ],
        ),
      ),
    );
  }

  void _showDemoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ink,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: BattlePassDemoMode.values
                  .map((mode) {
                    return ListTile(
                      title: Text(switch (mode) {
                        BattlePassDemoMode.premiumLocked =>
                          'Премиум не приобретен',
                        BattlePassDemoMode.premiumUnlocked =>
                          'Премиум приобретен',
                        BattlePassDemoMode.premiumWithXpBonus =>
                          'Премиум +100% опыта',
                        BattlePassDemoMode.maxLevel => 'Максимальный уровень',
                        BattlePassDemoMode.completed => 'Battle Pass завершен',
                      }),
                      onTap: () {
                        Navigator.pop(context);
                        onDemoModeSelected(mode);
                      },
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}
