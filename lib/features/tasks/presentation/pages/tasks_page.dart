import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../battle_pass/presentation/cubit/battle_pass_cubit.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import '../models/tasks_progress_summary.dart';
import '../widgets/tasks_content.dart';

@RoutePage()
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pass = context.select((BattlePassCubit cubit) => cubit.state.battlePass);

    return BlocConsumer<TasksCubit, TasksState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        if (state.status == TasksViewStatus.loading || state.status == TasksViewStatus.initial) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }
        if (state.status == TasksViewStatus.failure) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: FilledButton(onPressed: () => context.read<TasksCubit>().load(), child: const Text('Повторить загрузку')),
              ),
            ),
          );
        }

        return TasksContent(
          progress: pass == null
              ? null
              : TasksProgressSummary(currentLevel: pass.progress.currentLevel, currentXp: pass.progress.currentXp, nextLevelXp: pass.progress.nextLevelXp, tasksRefreshAt: pass.season.endsAt),
          tasks: pass?.tasks ?? const [],
          onBack: () => context.router.maybePop(),
          onExit: () => context.router.replaceAll([const GameRoute()]),
          onPurchasePremium: () => context.read<BattlePassCubit>().purchasePremium(),
        );
      },
    );
  }
}
