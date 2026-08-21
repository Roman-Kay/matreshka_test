import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';
import '../widgets/battle_pass_content.dart';
import '../widgets/battle_pass_frame.dart';

class BattlePassPage extends StatelessWidget {
  const BattlePassPage({super.key});

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
          return BattlePassFrame(child: BattlePassContent(state: state));
        },
      ),
    );
  }
}
