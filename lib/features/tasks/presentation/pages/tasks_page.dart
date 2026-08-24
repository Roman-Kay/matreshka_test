import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../battle_pass/data/repositories/mock_battle_pass_repository.dart';
import '../../../battle_pass/domain/models/battle_pass_models.dart';
import '../../../battle_pass/presentation/cubit/battle_pass_cubit.dart';
import '../../../battle_pass/presentation/widgets/level_badge.dart';
import '../../../battle_pass/presentation/widgets/premium_action_button.dart';

@RoutePage()
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TasksContent(
          tasks: mockBattlePassTasks,
          onBack: () => Navigator.pop(context),
        ),
      ),
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
      pass: pass,
      tasks: pass?.tasks ?? mockBattlePassTasks,
      onBack: () => context.maybePop(),
    );
  }
}

class TasksContent extends StatelessWidget {
  const TasksContent({super.key, this.pass, required this.tasks, this.onBack});

  final BattlePass? pass;
  final List<BattlePassTask> tasks;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(AppAssets.bgTask, fit: BoxFit.cover),
        Positioned(
          left: 52.w,
          top: 24.h,
          right: 52.w,
          child: _TasksHeader(pass: pass, onClose: onBack),
        ),
        Positioned.fill(
          top: 148.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 52.w),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => _TaskCard(task: tasks[index]),
            separatorBuilder: (context, index) => SizedBox(width: 40.w),
            itemCount: tasks.length,
          ),
        ),
        Positioned(
          left: 52.w,
          bottom: 46.h,
          child: Row(
            children: [
              PremiumActionButton(
                iconAsset: AppAssets.premium,
                text: 'Прокачать',
                onPressed: () =>
                    context.read<BattlePassCubit>().purchasePremium(),
              ),
              SizedBox(width: 52.w),
              const _UpgradeHintText(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader({required this.pass, required this.onClose});

  final BattlePass? pass;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final progress =
        pass?.progress ??
        const BattlePassProgress(
          currentLevel: 1,
          currentXp: 500,
          nextLevelXp: 1600,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onClose != null) ...[
          _TasksHeaderIconButton(
            assetPath: AppAssets.arrowLeft,
            onTap: onClose!,
          ),
          SizedBox(width: 40.w),
        ],
        BattlePassLevelBadge(progress: progress),
        SizedBox(width: 40.w),
        Padding(
          padding: EdgeInsets.only(top: 13.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: const Color(0x11E9E9F3),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.clock,
                          width: 32.r,
                          height: 32.r,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white40,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          '15д 12ч 42м',
                          style: TextStyle(
                            color: AppColors.white40,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                            letterSpacing: -0.26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Text(
                    'До обновления заданий',
                    style: TextStyle(
                      color: const Color(0xFF398652),
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.20,
                      letterSpacing: -0.26,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Задания боевого пропуска',
                style: TextStyle(
                  color: AppColors.white40,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.30,
                  letterSpacing: -0.48,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (onClose != null)
          _TasksHeaderIconButton(assetPath: AppAssets.close, onTap: onClose!),
      ],
    );
  }
}

class _TasksHeaderIconButton extends StatelessWidget {
  const _TasksHeaderIconButton({required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: AppColors.white5,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: SvgPicture.asset(assetPath, width: 36.r, height: 36.r),
      ),
    );
  }
}

class _UpgradeHintText extends StatelessWidget {
  const _UpgradeHintText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'На',
            style: TextStyle(
              color: const Color(0x99E9E9F3),
              fontSize: 40.sp,
              fontWeight: FontWeight.w300,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: const Color(0x7FFFD149),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: '25%',
            style: TextStyle(
              color: const Color(0xCCFFD149),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: const Color(0x7FFFD149),
              fontSize: 40.sp,
              fontWeight: FontWeight.w600,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
          TextSpan(
            text: 'быстрее с прокачкой!',
            style: TextStyle(
              color: const Color(0x99E9E9F3),
              fontSize: 40.sp,
              fontWeight: FontWeight.w300,
              height: 1.30,
              letterSpacing: -0.40,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final BattlePassTask task;

  @override
  Widget build(BuildContext context) {
    final done = task.completed;

    return SizedBox(
      width: 394.w,
      height: 502.h,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 161.h,
            child: Container(
              width: 394.w,
              height: 341.h,
              decoration: BoxDecoration(
                color: const Color(0xFF7C1404),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.r),
                  bottomRight: Radius.circular(60.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 394.w,
              height: 161.h,
              decoration: BoxDecoration(
                color: const Color(0xFF530202),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.r),
                  topRight: Radius.circular(60.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 33.w,
            top: 15.h,
            child: Image.asset(
              task.rewardAssetPath,
              width: 131.r,
              height: 131.r,
            ),
          ),
          Positioned(
            left: 187.w,
            top: 33.h,
            child: Container(
              width: 166.w,
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF65231),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                task.rewardTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white100,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.22,
                ),
              ),
            ),
          ),
          Positioned(
            left: 187.w,
            top: 91.h,
            child: SizedBox(
              width: 139.w,
              height: 40.h,
              child: Text(
                'x ${task.rewardAmount}',
                style: TextStyle(
                  color: const Color(0x7FE9E9F3),
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ),
          Positioned(
            top: 186.h,
            left: 0,
            right: 0,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${task.currentProgress}',
                    style: const TextStyle(color: AppColors.secondary50),
                  ),
                  const TextSpan(
                    text: ' ',
                    style: TextStyle(color: AppColors.white60),
                  ),
                  const TextSpan(
                    text: '/ ',
                    style: TextStyle(color: AppColors.white40),
                  ),
                  TextSpan(
                    text: '${task.requiredProgress}',
                    style: const TextStyle(color: AppColors.white100),
                  ),
                ],
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.30,
                  letterSpacing: -0.36,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 37.w,
            top: 268.h,
            child: SizedBox(
              width: 322.w,
              child: Text(
                task.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xCCE9E9F3),
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.22,
                ),
              ),
            ),
          ),
          Positioned(
            left: 37.w,
            top: 377.h,
            child: Container(
              width: 250.w,
              height: 90.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: done
                      ? const [Color(0xFF9E431F), Color(0xFFB95835)]
                      : const [Color(0xFFE22929), Color(0xFFFF6435)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(6.r),
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10.w,
                  children: [
                    if (done)
                      Icon(
                        Icons.check_rounded,
                        size: 24.r,
                        color: AppColors.secondary50,
                      ),
                    Text(
                      done ? 'Готово' : 'Перейти',
                      style: TextStyle(
                        color: AppColors.white100,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                        letterSpacing: -0.26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 297.w,
            top: 377.h,
            child: Container(
              width: 60.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: const Color(0xFF530202),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(30.r),
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: AppColors.white40,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
