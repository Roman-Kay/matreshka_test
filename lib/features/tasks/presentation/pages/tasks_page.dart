import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../battle_pass/presentation/cubit/battle_pass_cubit.dart';
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

    return TasksContent(
      progress: pass == null
          ? null
          : TasksProgressSummary(
              currentLevel: pass.progress.currentLevel,
              currentXp: pass.progress.currentXp,
              nextLevelXp: pass.progress.nextLevelXp,
              tasksRefreshAt: pass.season.endsAt,
            ),
      tasks: pass?.tasks ?? const [],
      onBack: () => context.router.maybePop(),
      onExit: () => context.router.replaceAll([const GameRoute()]),
      onPurchasePremium: () =>
          context.read<BattlePassCubit>().purchasePremium(),
    );
  }
}
