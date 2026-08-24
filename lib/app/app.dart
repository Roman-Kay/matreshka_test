import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../core/theme/app_theme.dart';
import '../features/battle_pass/data/repositories/mock_battle_pass_repository.dart';
import '../features/battle_pass/domain/repositories/battle_pass_repository.dart';
import '../features/battle_pass/presentation/cubit/battle_pass_cubit.dart';
import '../features/tasks/data/repositories/mock_tasks_repository.dart';
import '../features/tasks/domain/repositories/tasks_repository.dart';
import 'app_router.dart';

class BattlePassApp extends StatelessWidget {
  BattlePassApp({super.key, BattlePassRepository? repository})
    : _repository = repository,
      _appRouter = AppRouter();

  final BattlePassRepository? _repository;
  final AppRouter _appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TasksRepository>(
          create: (_) => const MockTasksRepository(),
        ),
        RepositoryProvider<BattlePassRepository>(
          create: (context) =>
              _repository ??
              MockBattlePassRepository(
                tasksRepository: context.read<TasksRepository>(),
              ),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            BattlePassCubit(context.read<BattlePassRepository>())..load(),
        child: ScreenUtilPlusInit(
          designSize: const Size(2320, 1080),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Battle Pass',
              theme: AppTheme.dark,
              debugShowCheckedModeBanner: false,
              routerConfig: _appRouter.config(),
            );
          },
        ),
      ),
    );
  }
}
