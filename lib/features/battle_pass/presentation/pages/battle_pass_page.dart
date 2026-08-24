import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';
import '../widgets/battle_pass_content.dart';

@RoutePage()
class BattlePassPage extends StatelessWidget {
  const BattlePassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattlePassCubit, BattlePassState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        if (state.status == BattlePassViewStatus.loading ||
            state.status == BattlePassViewStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == BattlePassViewStatus.failure ||
            state.battlePass == null) {
          return Center(
            child: FilledButton(
              onPressed: () => context.read<BattlePassCubit>().load(),
              child: const Text('Повторить загрузку'),
            ),
          );
        }
        return BattlePassContent(
          state: state,
          onExitToGame: () => context.router.replaceAll([const GameRoute()]),
          onPurchasePremium: () =>
              context.read<BattlePassCubit>().purchasePremium(),
          onClaimAllRewards: () =>
              context.read<BattlePassCubit>().claimAllAvailableRewards(),
          onClaimTask: (taskId) =>
              context.read<BattlePassCubit>().claimTask(taskId),
          onSelectReward: (rewardId) =>
              context.read<BattlePassCubit>().selectReward(rewardId),
          onClaimReward: (rewardId) =>
              context.read<BattlePassCubit>().claimReward(rewardId),
          onDemoModeSelected: (mode) =>
              context.read<BattlePassCubit>().switchDemoMode(mode),
        );
      },
    );
  }
}
