import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:romankaygo_test_rp/core/constants/app_assets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';

class TasksPreview extends StatefulWidget {
  const TasksPreview({
    super.key,
    required this.tasks,
    required this.onTap,
    required this.onClaim,
  });

  final List<BattlePassTask> tasks;
  final VoidCallback onTap;
  final ValueChanged<int> onClaim;

  @override
  State<TasksPreview> createState() => _TasksPreviewState();
}

class _TasksPreviewState extends State<TasksPreview> {
  late final PageController _textPageController;
  Timer? _autoScrollTimer;
  var _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _textPageController = PageController();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.tasks.length < 2) return;
      final nextIndex = (_activeIndex + 1) % widget.tasks.length;
      if (!_textPageController.hasClients) {
        setState(() => _activeIndex = nextIndex);
        return;
      }
      _textPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _textPageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TasksPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks.isEmpty) return;
    if (_activeIndex >= widget.tasks.length) {
      _activeIndex = widget.tasks.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    if (tasks.isEmpty) return const SizedBox.shrink();
    final activeTask = tasks[_activeIndex];

    return Padding(
      padding: EdgeInsets.only(left: 61.w, top: 59.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -120) _goToTask(_activeIndex + 1);
          if (velocity > 120) _goToTask(_activeIndex - 1);
        },
        child: SizedBox(
          width: 400.w,
          child: Column(
            children: [
              Container(
                height: 110.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF353747).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _TaskPreviewHeader(
                    key: ValueKey('header-${tasks[_activeIndex].id}'),
                    task: tasks[_activeIndex],
                    taskIndex: _activeIndex,
                    taskCount: tasks.length,
                  ),
                ),
              ),
              Container(
                height: 290.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF202231).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 44),
                    SizedBox(
                      width: 320.w,
                      height: 54.h,
                      child: PageView.builder(
                        controller: _textPageController,
                        itemCount: tasks.length,
                        onPageChanged: (index) =>
                            setState(() => _activeIndex = index),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Text(
                            task.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: task.claimed
                                  ? AppColors.white60.withValues(alpha: 0.4)
                                  : AppColors.white60,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.20,
                              letterSpacing: -0.22,
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(flex: 50),
                    _ProgressSegments(
                      count: tasks.length,
                      activeIndex: _activeIndex,
                    ),
                    SizedBox(height: 26.h),
                    _TaskPreviewActionButton(
                      task: activeTask,
                      onOpenTasks: widget.onTap,
                      onClaim: () => widget.onClaim(activeTask.id),
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToTask(int index) {
    if (widget.tasks.isEmpty) return;
    final nextIndex = index.clamp(0, widget.tasks.length - 1);
    if (nextIndex == _activeIndex) return;

    setState(() => _activeIndex = nextIndex);
    if (!_textPageController.hasClients) return;
    _textPageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}

class _TaskPreviewHeader extends StatelessWidget {
  const _TaskPreviewHeader({
    super.key,
    required this.task,
    required this.taskIndex,
    required this.taskCount,
  });

  final BattlePassTask task;
  final int taskIndex;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final opacity = task.claimed ? 0.4 : 1.0;

    return Center(
      child: SizedBox(
        width: 320.w,
        child: Row(
          children: [
            Opacity(
              opacity: opacity,
              child: Image.asset(
                task.rewardAssetPath,
                width: 96.r,
                height: 96.r,
              ),
            ),
            SizedBox(width: 12.w),
            Opacity(
              opacity: opacity,
              child: Text(
                'x ${task.rewardAmount}',
                style: TextStyle(
                  color: AppColors.white100,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                  letterSpacing: -0.26,
                ),
              ),
            ),
            const Spacer(),
            if (task.claimed)
              Container(
                width: 132.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.background5,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 42.r,
                    color: const Color(0xFF2DDB72),
                  ),
                ),
              )
            else
              Container(
                width: 112.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.background5,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${taskIndex + 1}',
                          style: TextStyle(
                            color: AppColors.secondary50,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                            letterSpacing: -0.26,
                          ),
                        ),
                        TextSpan(
                          text: ' / $taskCount',
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskPreviewActionButton extends StatelessWidget {
  const _TaskPreviewActionButton({
    required this.task,
    required this.onOpenTasks,
    required this.onClaim,
  });

  final BattlePassTask task;
  final VoidCallback onOpenTasks;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final isClaim = task.canClaim;
    final isClaimed = task.claimed;

    return GestureDetector(
      onTap: isClaim ? onClaim : onOpenTasks,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 320.w,
            height: isClaim ? null : 74.h,
            padding: isClaim
                ? EdgeInsets.fromLTRB(36.w, 20.h, 36.w, 23.h)
                : null,
            decoration: BoxDecoration(
              color: isClaim ? null : AppColors.white10,
              gradient: isClaim
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF55B675), Color(0xFF449761)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16.w,
              children: [
                if (!isClaim)
                  SvgPicture.asset(AppAssets.tasks, width: 30.r, height: 30.r),
                Text(
                  isClaim ? 'Забрать опыт' : 'Задания',
                  style: TextStyle(
                    color: isClaim
                        ? const Color(0xFF68C286)
                        : AppColors.white100,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.20,
                    letterSpacing: -0.26,
                  ),
                ),
              ],
            ),
          ),
          if (isClaimed)
            Positioned(
              right: -16.w,
              top: -26.h,
              child: Image.asset(AppAssets.danger, width: 58.r, height: 58.r),
            ),
        ],
      ),
    );
  }
}

class BattlePassCompletedNotice extends StatelessWidget {
  const BattlePassCompletedNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 51.w, top: 110.h),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 52.h),
            child: Container(
              padding: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 32.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: GradientBoxBorder(
                  width: 4.r,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFA34E),
                      Color(0xFFFFC847),
                      Color(0xFFFFE383),
                      Color(0xFFFFB51B),
                      Color(0xFFFF7B5F),
                    ],
                  ),
                ),
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: [
                  BoxShadow(color: const Color(0x51FFB800), blurRadius: 100.r),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Battle Pass завершен',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                      letterSpacing: -0.36,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: 386.w,
                    child: Text(
                      'Успей забрать оставшиеся награды!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white40,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                        letterSpacing: -0.26,
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  const _CompletedTimerPill(),
                ],
              ),
            ),
          ),

          Image.asset(AppAssets.danger, height: 110.h),
        ],
      ),
    );
  }
}

class _CompletedTimerPill extends StatefulWidget {
  const _CompletedTimerPill();

  @override
  State<_CompletedTimerPill> createState() => _CompletedTimerPillState();
}

class _CompletedTimerPillState extends State<_CompletedTimerPill>
    with TickerProviderStateMixin {
  static const _figmaEase = Cubic(0, 0, 0.58, 1);

  late final AnimationController _settleController;
  late final Animation<double> _settleOffset;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _settleOffset = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _settleController, curve: _figmaEase));
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settleOffset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            -90.w * _settleOffset.value,
            90.h * _settleOffset.value,
          ),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.00, -0.00),
            end: Alignment(1.00, 1.00),
            colors: [
              const Color(0xFFFFA24D),
              const Color(0xFFFFC847),
              const Color(0xFFFFB51B),
              const Color(0xFFFF7B5E),
            ],
          ),
          borderRadius: BorderRadius.circular(60.r),
        ),
        child: Text(
          '6д 13ч 55м',
          style: TextStyle(
            color: AppColors.dark100,
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
            height: 1.20,
            letterSpacing: -0.30,
          ),
        ),
      ),
    );
  }
}

class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  static const _activeColor = AppColors.white60;
  static const _inactiveColor = AppColors.white10;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final divWidth = 12.w;
    final totalWidth = divWidth * (count - 1);
    final segmentWidth = (320.w - totalWidth) / count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++) ...[
          Container(
            width: segmentWidth,
            height: 8.h,
            decoration: BoxDecoration(
              color: index == activeIndex ? _activeColor : _inactiveColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          if (index != count - 1) SizedBox(width: divWidth),
        ],
      ],
    );
  }
}
