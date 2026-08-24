import 'package:auto_route/auto_route.dart';

import '../features/battle_pass/presentation/pages/battle_pass_home_page.dart';
import '../features/battle_pass/presentation/pages/battle_pass_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: BattlePassRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(page: BattlePassHomeRoute.page, path: '', initial: true),
        CustomRoute(
          page: BattlePassTasksRoute.page,
          path: 'tasks',
          transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
          duration: const Duration(milliseconds: 320),
          reverseDuration: const Duration(milliseconds: 260),
        ),
      ],
    ),
  ];
}
