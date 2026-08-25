import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: GoogleFonts.geologicaTextTheme(),
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: const ColorScheme.dark(primary: AppColors.orange, secondary: AppColors.gold, surface: AppColors.panel),
      useMaterial3: true,
    );
  }
}
