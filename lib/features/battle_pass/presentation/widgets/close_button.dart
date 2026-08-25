import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class BattlePassCloseButton extends StatelessWidget {
  const BattlePassCloseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(onPressed: onTap, iconSize: 42.r, tooltip: 'Обновить', icon: const Icon(Icons.close));
  }
}
