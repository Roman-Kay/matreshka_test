import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final landscapeWithFrontCameraLeft =
      defaultTargetPlatform == TargetPlatform.android
      ? DeviceOrientation.landscapeLeft
      : DeviceOrientation.landscapeRight;

  await SystemChrome.setPreferredOrientations([landscapeWithFrontCameraLeft]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );
  runApp(BattlePassApp());
}
