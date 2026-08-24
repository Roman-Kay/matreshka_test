import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class UpgradeHintText extends StatelessWidget {
  const UpgradeHintText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'На',
            style: TextStyle(
              color: const Color(0x99E9E9F3),
              fontSize: 40.sp,
              fontWeight: FontWeight.w300,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: const Color(0x7FFFD149),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: '25%',
            style: TextStyle(
              color: const Color(0xCCFFD149),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: const Color(0x7FFFD149),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: 'быстрее с прокачкой!',
            style: TextStyle(
              color: const Color(0x99E9E9F3),
              fontSize: 40.sp,
              fontWeight: FontWeight.w300,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
        ],
      ),
    );
  }
}
