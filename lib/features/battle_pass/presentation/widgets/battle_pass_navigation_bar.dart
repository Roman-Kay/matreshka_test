import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/theme/app_colors.dart';

class BattlePassNavigationBar extends StatelessWidget {
  const BattlePassNavigationBar({super.key, required this.selectedLabel, required this.onSelected});

  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavHitTarget(label: 'Ивент', selected: selectedLabel == 'Ивент', onTap: onSelected),
          _NavHitTarget(label: 'Battle Pass', selected: selectedLabel == 'Battle Pass', onTap: onSelected),
          _NavHitTarget(label: 'Календарь новичка', selected: selectedLabel == 'Календарь новичка', onTap: onSelected),
          _NavHitTarget(label: 'После уроков', selected: selectedLabel == 'После уроков', onTap: onSelected),
          _NavHitTarget(label: 'Пригласи друга', selected: selectedLabel == 'Пригласи друга', onTap: onSelected),
          _NavHitTarget(label: 'Промокод', selected: selectedLabel == 'Промокод', onTap: onSelected),
        ],
      ),
    );
  }
}

class _NavHitTarget extends StatelessWidget {
  const _NavHitTarget({required this.label, required this.onTap, this.selected = false});

  final String label;
  final ValueChanged<String> onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.white40;
    return SizedBox(
      width: 120.w,
      height: 120.h,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => onTap(label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NavIcon(label: label, color: color),
            SizedBox(height: 11.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 22.sp, height: 1.2, fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
            ),
            SizedBox(height: 11.h),
          ],
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
    final icon = switch (label) {
      'Ивент' => Icons.emoji_events,
      'Календарь новичка' => Icons.event_available,
      'После уроков' => Icons.calendar_month,
      'Пригласи друга' => Icons.person_add_alt_1,
      'Промокод' => Icons.confirmation_num,
      _ => Icons.circle,
    };
    return Icon(icon, size: 54.r, color: color);
  }
}
