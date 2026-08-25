import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/pause_menu_section.dart';

class PauseNavigationBar extends StatelessWidget {
  const PauseNavigationBar({super.key, required this.selectedSection, required this.onSelected, this.notificationSections = const {}});

  final PauseMenuSection selectedSection;
  final ValueChanged<PauseMenuSection> onSelected;
  final Set<PauseMenuSection> notificationSections;

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
              children: PauseMenuSection.values
                  .map((section) => _NavHitTarget(section: section, selected: selectedSection == section, hasNotification: notificationSections.contains(section), onTap: onSelected))
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavHitTarget extends StatelessWidget {
  const _NavHitTarget({required this.section, required this.onTap, this.selected = false, this.hasNotification = false});

  final PauseMenuSection section;
  final ValueChanged<PauseMenuSection> onTap;
  final bool selected;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    final colorSvg = selected ? AppColors.white100 : AppColors.white40;
    final colorText = selected ? AppColors.white60 : AppColors.white30;

    return SizedBox(
      height: 130.h,
      width: 130.w,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => onTap(section),
          child: Column(
            children: [
              SizedBox(
                width: 72.w,
                height: 72.h,
                child: Stack(
                  children: [
                    SvgPicture.asset(section.iconAsset, height: 72.h, colorFilter: ColorFilter.mode(colorSvg, BlendMode.srcIn)),
                    if (hasNotification)
                      Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(radius: 6.r, backgroundColor: AppColors.primary10),
                      ),
                  ],
                ),
              ),
              SizedBox(height: section.iconLabelSpacing.h),
              Text(
                section.label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorText, fontSize: 22.sp, fontWeight: FontWeight.w400, height: 1.20, letterSpacing: -0.22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
