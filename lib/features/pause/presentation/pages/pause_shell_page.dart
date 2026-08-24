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
                  selectedSection:
                      PauseMenuSection.values[tabsRouter.activeIndex],
                  onSelected: (section) {
                    tabsRouter.setActiveIndex(section.index);
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
}
