import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../app/routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_state.dart';
import '../models/pause_menu_section.dart';
import 'battle_pass_header.dart';
import 'battle_pass_navigation_bar.dart';
import 'battle_pass_navigation_panel.dart';
import 'premium_panel.dart';
import 'reward_rail.dart';
import 'reward_title.dart';
import 'tasks_preview.dart';

class BattlePassContent extends StatefulWidget {
  const BattlePassContent({
    super.key,
    required this.state,
    required this.onExitToGame,
  });

  final BattlePassState state;
  final VoidCallback onExitToGame;

  @override
  State<BattlePassContent> createState() => _BattlePassContentState();
}

class _BattlePassContentState extends State<BattlePassContent> {
  PauseMenuSection _activeSection = PauseMenuSection.battlePass;
  final _contentNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final pass = widget.state.battlePass!;
    final selected = _selectedReward(pass, widget.state.selectedRewardId);
    final choiceRewards = _selectedChoiceRewards(
      pass,
      widget.state.selectedRewardId,
    );
    final isBattlePass = _activeSection == PauseMenuSection.battlePass;
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final completed = widget.state.demoMode == BattlePassDemoMode.completed;

    return Row(
      children: [
        BattlePassNavigationBar(
          selectedSection: _activeSection,
          onSelected: (section) => setState(() {
            _activeSection = section;
            _contentNavigatorKey.currentState?.popUntil(
              (route) => route.isFirst,
            );
          }),
        ),
        Expanded(
          child: isBattlePass
              ? Navigator(
                  key: _contentNavigatorKey,
                  initialRoute: AppRoutes.battlePass,
                  onGenerateRoute: (settings) {
                    final child = switch (settings.name) {
                      AppRoutes.tasks => TasksContent(
                        tasks: pass.tasks,
                        onBack: () => _contentNavigatorKey.currentState?.pop(),
                        onExit: widget.onExitToGame,
                      ),
                      _ => _BattlePassHome(
                        pass: pass,
                        state: widget.state,
                        selected: selected,
                        choiceRewards: choiceRewards,
                        premiumLocked: premiumLocked,
                        completed: completed,
                        onExitToGame: widget.onExitToGame,
                        onTasksTap: () => _contentNavigatorKey.currentState
                            ?.pushNamed(AppRoutes.tasks),
                      ),
                    };

                    return PageRouteBuilder<void>(
                      settings: settings,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          child,
                      transitionDuration: const Duration(milliseconds: 320),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 260,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );
                            final isTasksRoute =
                                settings.name == AppRoutes.tasks;
                            final offset = Tween<Offset>(
                              begin: Offset(isTasksRoute ? 0.08 : -0.04, 0),
                              end: Offset.zero,
                            ).animate(curvedAnimation);

                            return FadeTransition(
                              opacity: curvedAnimation,
                              child: SlideTransition(
                                position: offset,
                                child: child,
                              ),
                            );
                          },
                    );
                  },
                )
              : BattlePassNavigationPanel(section: _activeSection),
        ),
      ],
    );
  }

  BattlePassReward? _selectedReward(BattlePass pass, int? id) {
    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        if (reward.id == id) return reward;
      }
    }
    return null;
  }

  List<BattlePassReward> _selectedChoiceRewards(BattlePass pass, int? id) {
    if (id == null) return const [];

    for (final level in pass.season.levels) {
      final rewards = [...level.freeRewards, ...level.premiumRewards];
      if (!rewards.any((reward) => reward.id == id)) continue;
      return level.premiumRewards.length > 1 ? level.premiumRewards : const [];
    }

    return const [];
  }
}

class _BattlePassHome extends StatelessWidget {
  const _BattlePassHome({
    required this.pass,
    required this.state,
    required this.selected,
    required this.choiceRewards,
    required this.premiumLocked,
    required this.completed,
    required this.onExitToGame,
    required this.onTasksTap,
  });

  final BattlePass pass;
  final BattlePassState state;
  final BattlePassReward? selected;
  final List<BattlePassReward> choiceRewards;
  final bool premiumLocked;
  final bool completed;
  final VoidCallback onExitToGame;
  final VoidCallback onTasksTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          // для центровки контейнера с выбранной наградой, чтобы он был по центру bg картинки, а не по центру экрана
          padding: EdgeInsets.only(top: 105.h, right: 105.w),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Image.asset(
                  selected?.assetPath ?? AppAssets.hero,
                  height: 521.h,
                  width: 521.w,
                ),
                RewardTitle(
                  reward: selected,
                  choiceRewards: choiceRewards,
                  premiumLocked: premiumLocked,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PremiumPanel(pass: pass),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            BattlePassHeader(pass: pass, onClose: onExitToGame),
            completed
                ? const BattlePassCompletedNotice()
                : TasksPreview(tasks: pass.tasks, onTap: onTasksTap),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 300.h,
                  child: RewardRail(state: state),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
