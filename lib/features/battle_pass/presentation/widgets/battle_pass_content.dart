import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../app/routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';
import 'battle_pass_header.dart';
import 'battle_pass_navigation_bar.dart';
import 'battle_pass_navigation_panel.dart';
import 'close_button.dart';
import 'premium_panel.dart';
import 'reward_rail.dart';
import 'reward_title.dart';
import 'tasks_preview.dart';

class BattlePassContent extends StatefulWidget {
  const BattlePassContent({super.key, required this.state});

  final BattlePassState state;

  @override
  State<BattlePassContent> createState() => _BattlePassContentState();
}

class _BattlePassContentState extends State<BattlePassContent> {
  String _activePanel = 'Battle Pass';

  @override
  Widget build(BuildContext context) {
    final pass = widget.state.battlePass!;
    final selected = _selectedReward(pass, widget.state.selectedRewardId);
    final isBattlePass = _activePanel == 'Battle Pass';

    return Row(
      children: [
        BattlePassNavigationBar(selectedLabel: _activePanel, onSelected: (label) => setState(() => _activePanel = label)),
        Expanded(
          child: Stack(
            children: [
              if (isBattlePass) ...[
                Column(
                  children: [
                    SizedBox(height: 32.h),
                    BattlePassHeader(pass: pass),
                  ],
                ),
                // Positioned(
                //   left: 820.w,
                //   top: 70.h,
                //   width: 760.w,
                //   height: 560.h,
                //   child: Image.asset(selected?.assetPath ?? AppAssets.hero, fit: BoxFit.contain),
                // ),
                // Positioned(
                //   left: 850.w,
                //   top: 580.h,
                //   width: 780.w,
                //   child: RewardTitle(reward: selected, premiumLocked: pass.premiumStatus == PremiumStatus.locked),
                // ),
                // Positioned(
                //   left: 346.w,
                //   top: 220.h,
                //   child: TasksPreview(onTap: () => Navigator.pushNamed(context, AppRoutes.tasks)),
                // ),
                // Positioned(
                //   right: 80.w,
                //   top: 335.h,
                //   child: PremiumPanel(pass: pass),
                // ),
                // Positioned(
                //   left: 346.w,
                //   right: 80.w,
                //   bottom: 50.h,
                //   height: 360.h,
                //   child: RewardRail(state: widget.state),
                // ),
              ] else ...[
                BattlePassNavigationPanel(title: _activePanel),
              ],
              // Positioned(
              //   right: 80.w,
              //   top: 20.h,
              //   child: BattlePassCloseButton(onTap: () => context.read<BattlePassCubit>().load()),
              // ),
            ],
          ),
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
}
