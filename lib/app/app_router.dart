import 'package:auto_route/auto_route.dart';

import '../features/after_lessons/presentation/pages/after_lessons_page.dart';
import '../features/battle_pass/presentation/pages/battle_pass_page.dart';
import '../features/event/presentation/pages/event_page.dart';
import '../features/game/presentation/pages/game_page.dart';
import '../features/invite_friend/presentation/pages/invite_friend_page.dart';
import '../features/newcomer_calendar/presentation/pages/newcomer_calendar_page.dart';
import '../features/pause/presentation/pages/pause_shell_page.dart';
import '../features/promo/presentation/pages/promo_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: GameRoute.page, path: '/', initial: true),
    CustomRoute(
      page: PauseShellRoute.page,
      path: '/pause',
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
      children: [
        AutoRoute(page: EventRoute.page, path: 'event'),
        AutoRoute(
          page: BattlePassRoute.page,
          path: 'battle-pass',
          initial: true,
        ),
        CustomRoute(
          page: BattlePassTasksRoute.page,
          path: 'battle-pass/tasks',
          transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
          duration: const Duration(milliseconds: 320),
          reverseDuration: const Duration(milliseconds: 260),
        ),
        AutoRoute(page: NewcomerCalendarRoute.page, path: 'calendar'),
        AutoRoute(page: AfterLessonsRoute.page, path: 'after-lessons'),
        AutoRoute(page: InviteFriendRoute.page, path: 'invite-friend'),
        AutoRoute(page: PromoRoute.page, path: 'promo'),
      ],
    ),
  ];
}
