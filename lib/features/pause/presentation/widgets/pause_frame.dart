import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class PauseFrame extends StatelessWidget {
  const PauseFrame({super.key, required this.child});

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
