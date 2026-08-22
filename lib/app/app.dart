import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../core/theme/app_theme.dart';
import '../features/battle_pass/data/repositories/mock_battle_pass_repository.dart';
import '../features/battle_pass/domain/repositories/battle_pass_repository.dart';
import '../features/battle_pass/presentation/cubit/battle_pass_cubit.dart';
import '../features/battle_pass/presentation/pages/battle_pass_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';
import 'routes.dart';

class BattlePassApp extends StatelessWidget {
  const BattlePassApp({super.key, BattlePassRepository? repository}) : _repository = repository;

  final BattlePassRepository? _repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<BattlePassRepository>(
      create: (_) => _repository ?? const MockBattlePassRepository(),
      child: BlocProvider(
        create: (context) => BattlePassCubit(context.read<BattlePassRepository>())..load(),
        child: ScreenUtilPlusInit(
          designSize: const Size(2320, 1080),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Battle Pass',
              theme: AppTheme.dark,
              debugShowCheckedModeBanner: false,
              routes: {AppRoutes.battlePass: (_) => const BattlePassPage(), AppRoutes.tasks: (_) => const TasksPage()},
            );
          },
        ),
      ),
    );
  }
}
