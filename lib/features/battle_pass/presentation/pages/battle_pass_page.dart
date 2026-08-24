import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';
import '../widgets/battle_pass_frame.dart';
import '../widgets/battle_pass_navigation_bar.dart';
import '../widgets/battle_pass_navigation_panel.dart';

@RoutePage()
class BattlePassPage extends StatefulWidget {
  const BattlePassPage({super.key});

  @override
  State<BattlePassPage> createState() => _BattlePassPageState();
}

class _BattlePassPageState extends State<BattlePassPage> {
  String _activePanel = 'Battle Pass';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BattlePassCubit, BattlePassState>(
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
            return const BattlePassFrame(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == BattlePassViewStatus.failure ||
              state.battlePass == null) {
            return BattlePassFrame(
              child: Center(
                child: FilledButton(
                  onPressed: () => context.read<BattlePassCubit>().load(),
                  child: const Text('Повторить загрузку'),
                ),
              ),
            );
          }
          return BattlePassFrame(
            child: Row(
              children: [
                BattlePassNavigationBar(
                  selectedLabel: _activePanel,
                  onSelected: (label) => setState(() => _activePanel = label),
                ),
                Expanded(
                  child: _activePanel == 'Battle Pass'
                      ? const AutoRouter()
                      : BattlePassNavigationPanel(title: _activePanel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
