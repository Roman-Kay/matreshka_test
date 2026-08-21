import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class BattlePassFrame extends StatelessWidget {
  const BattlePassFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(AppAssets.bg, fit: BoxFit.cover),
        child,
      ],
    );
  }
}
