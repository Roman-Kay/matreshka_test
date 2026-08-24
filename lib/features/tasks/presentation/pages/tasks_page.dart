import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../battle_pass/presentation/cubit/battle_pass_cubit.dart';
import '../../../pause/presentation/models/pause_menu_section.dart';
import '../../../pause/presentation/widgets/pause_frame.dart';
import '../../../pause/presentation/widgets/pause_navigation_bar.dart';
import '../models/tasks_progress_summary.dart';
import '../widgets/tasks_content.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: TasksContent(tasks: const [])),
    );
  }
}

@RoutePage()
class BattlePassTasksPage extends StatelessWidget {
  const BattlePassTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pass = context.select(
      (BattlePassCubit cubit) => cubit.state.battlePass,
    );

    return Scaffold(
      body: PauseFrame(
        child: Row(
          children: [
            PauseNavigationBar(
              selectedSection: PauseMenuSection.battlePass,
              onSelected: (section) => _openPauseSection(context, section),
            ),
            Expanded(
              child: TasksContent(
                progress: pass == null
                    ? null
                    : TasksProgressSummary(
                        currentLevel: pass.progress.currentLevel,
                        currentXp: pass.progress.currentXp,
                        nextLevelXp: pass.progress.nextLevelXp,
                      ),
                tasks: pass?.tasks ?? const [],
                onBack: () => context.router.maybePop(),
                onExit: () => context.router.replaceAll([const GameRoute()]),
                onPurchasePremium: () =>
                    context.read<BattlePassCubit>().purchasePremium(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPauseSection(BuildContext context, PauseMenuSection section) {
    if (section == PauseMenuSection.battlePass) {
      context.router.maybePop();
      return;
    }

    context.router.root.navigate(
      PauseShellRoute(children: [_routeForSection(section)]),
    );
  }

  PageRouteInfo _routeForSection(PauseMenuSection section) {
    return switch (section) {
      PauseMenuSection.event => const EventRoute(),
      PauseMenuSection.battlePass => const BattlePassRoute(),
      PauseMenuSection.calendar => const NewcomerCalendarRoute(),
      PauseMenuSection.afterLessons => const AfterLessonsRoute(),
      PauseMenuSection.inviteFriend => const InviteFriendRoute(),
      PauseMenuSection.promo => const PromoRoute(),
    };
  }
}
