import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../models/pause_menu_section.dart';
import '../widgets/pause_frame.dart';
import '../widgets/pause_navigation_bar.dart';

@RoutePage()
class PauseShellPage extends StatelessWidget {
  const PauseShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PauseFrame(
        child: AutoTabsRouter(
          routes: const [
            EventRoute(),
            BattlePassRoute(),
            BattlePassTasksRoute(),
            NewcomerCalendarRoute(),
            AfterLessonsRoute(),
            InviteFriendRoute(),
            PromoRoute(),
          ],
          builder: (context, child) {
            final tabsRouter = AutoTabsRouter.of(context);
            return Row(
              children: [
                PauseNavigationBar(
                  selectedSection: _sectionForIndex(tabsRouter.activeIndex),
                  onSelected: (section) {
                    tabsRouter.setActiveIndex(_indexForSection(section));
                  },
                ),
                Expanded(child: child),
              ],
            );
          },
        ),
      ),
    );
  }

  PauseMenuSection _sectionForIndex(int index) {
    return switch (index) {
      0 => PauseMenuSection.event,
      1 || 2 => PauseMenuSection.battlePass,
      3 => PauseMenuSection.calendar,
      4 => PauseMenuSection.afterLessons,
      5 => PauseMenuSection.inviteFriend,
      _ => PauseMenuSection.promo,
    };
  }

  int _indexForSection(PauseMenuSection section) {
    return switch (section) {
      PauseMenuSection.event => 0,
      PauseMenuSection.battlePass => 1,
      PauseMenuSection.calendar => 3,
      PauseMenuSection.afterLessons => 4,
      PauseMenuSection.inviteFriend => 5,
      PauseMenuSection.promo => 6,
    };
  }
}
