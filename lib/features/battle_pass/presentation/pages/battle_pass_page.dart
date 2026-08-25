import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';
import '../widgets/battle_pass_content.dart';

@RoutePage()
class BattlePassPage extends StatefulWidget {
  const BattlePassPage({super.key});

  @override
  State<BattlePassPage> createState() => _BattlePassPageState();
}

class _BattlePassPageState extends State<BattlePassPage> {
  TabsRouter? _tabsRouter;
  var _wasActive = false;
  var _entranceReplayToken = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabsRouter = TabsRouterScope.of(context)?.controller;
    if (_tabsRouter == tabsRouter) return;

    _tabsRouter?.removeListener(_handleTabsChanged);
    _tabsRouter = tabsRouter;
    _wasActive = _isBattlePassActive;
    _tabsRouter?.addListener(_handleTabsChanged);
  }

  @override
  void dispose() {
    _tabsRouter?.removeListener(_handleTabsChanged);
    super.dispose();
  }

  bool get _isBattlePassActive => _tabsRouter?.activeIndex == 1;

  void _handleTabsChanged() {
    final isActive = _isBattlePassActive;
    if (isActive && !_wasActive) {
      setState(() => _entranceReplayToken++);
    }
    _wasActive = isActive;
  }

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
          entranceReplayToken: _entranceReplayToken,
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
