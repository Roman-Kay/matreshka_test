import 'package:auto_route/auto_route.dart';

import '../features/battle_pass/presentation/pages/battle_pass_page.dart';
import '../features/game/presentation/pages/game_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: GameRoute.page, path: '/', initial: true),
    CustomRoute(
      page: PauseMenuRoute.page,
      path: '/pause',
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    ),
  ];
}
