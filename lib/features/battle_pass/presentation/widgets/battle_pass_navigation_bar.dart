import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class BattlePassNavigationBar extends StatelessWidget {
  const BattlePassNavigationBar({super.key, required this.selectedLabel, required this.onSelected});

  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final leftSafeArea = MediaQuery.of(context).padding.left;
    final leftPadding = leftSafeArea > 60 ? leftSafeArea : leftSafeArea + 20.w;
    final rightPadding = 20.w;
    final contentWidth = leftPadding + 120.w + rightPadding;

    return ColoredBox(
      color: AppColors.navBg,
      child: Stack(
        children: [
          Image.asset(AppAssets.navBackground, color: AppColors.red, width: contentWidth, height: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 48.h,
              children: [
                _NavHitTarget(label: 'Ивент', selected: selectedLabel == 'Ивент', onTap: onSelected, spasing: 7.h),
                _NavHitTarget(label: 'Battle Pass', selected: selectedLabel == 'Battle Pass', onTap: onSelected, spasing: 11.h),
                _NavHitTarget(label: 'Календарь\nновичка', selected: selectedLabel == 'Календарь\nновичка', onTap: onSelected, spasing: 0.h),
                _NavHitTarget(label: 'После\nуроков', selected: selectedLabel == 'После\nуроков', onTap: onSelected, spasing: 0.h),
                _NavHitTarget(label: 'Пригласи\nдруга', selected: selectedLabel == 'Пригласи\nдруга', onTap: onSelected, spasing: 0.h),
                _NavHitTarget(label: 'Промокод', selected: selectedLabel == 'Промокод', onTap: onSelected, spasing: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavHitTarget extends StatelessWidget {
  const _NavHitTarget({required this.label, required this.onTap, this.selected = false, required this.spasing});

  final String label;
  final ValueChanged<String> onTap;
  final bool selected;
  // для каждой иконки  svg разный отсуп с текстом, поэтому вынес в отдельный параметр, чтобы не городить switch/case
  final double spasing;

  @override
  Widget build(BuildContext context) {
    final colorSvg = selected ? AppColors.white100 : AppColors.white40;
    final colorText = selected ? AppColors.white60 : AppColors.white30;

    return SizedBox(
      height: 120.h,
      width: 120.w,
      child: Material(
        color: AppColors.transperent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => onTap(label),
          child: Column(
            children: [
              _NavIcon(label: label, color: colorSvg),
              SizedBox(height: spasing),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorText, fontSize: 22.h, height: 1, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final svg = switch (label) {
      'Ивент' => AppAssets.navEvent,
      'Календарь\nновичка' => AppAssets.navCalendar,
      'После\nуроков' => AppAssets.navAfter,
      'Пригласи\nдруга' => AppAssets.navInvite,
      'Промокод' => AppAssets.navPromo,
      _ => AppAssets.navBattlePass,
    };
    return SvgPicture.asset(svg, height: 72.h, color: color);
  }
}
