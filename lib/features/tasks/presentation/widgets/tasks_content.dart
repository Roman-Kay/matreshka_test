import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/ui/buttons/premium_action_button.dart';
import '../../domain/models/task.dart';
import '../models/tasks_progress_summary.dart';
import 'task_card.dart';
import 'tasks_header.dart';
import 'upgrade_hint_text.dart';

class TasksContent extends StatefulWidget {
  const TasksContent({super.key, this.progress, required this.tasks, this.onBack, this.onExit, this.onPurchasePremium, this.onClaimTask});

  final TasksProgressSummary? progress;
  final List<Task> tasks;
  final VoidCallback? onBack;
  final VoidCallback? onExit;
  final VoidCallback? onPurchasePremium;
  final ValueChanged<int>? onClaimTask;

  @override
  State<TasksContent> createState() => _TasksContentState();
}

class _TasksContentState extends State<TasksContent> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 680))..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(AppAssets.bgTask, fit: BoxFit.cover),
        Column(
          children: [
            _TasksEntranceTransition(
              animation: _entranceController,
              interval: const Interval(0.00, 0.62, curve: Curves.easeOutCubic),
              beginOffset: Offset(0, -96.h),
              child: TasksHeader(progress: widget.progress, onBack: widget.onBack, onExit: widget.onExit),
            ),
            SizedBox(height: 125.h),
            _TasksEntranceTransition(
              animation: _entranceController,
              interval: const Interval(0.12, 0.84, curve: Curves.easeOutCubic),
              beginOffset: Offset(0, 120.h),
              child: SizedBox(
                height: 502.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 51.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => TaskCard(task: widget.tasks[index], onClaim: widget.onClaimTask == null ? null : () => widget.onClaimTask!(widget.tasks[index].id)),
                  separatorBuilder: (context, index) => SizedBox(width: 26.25.w),
                  itemCount: widget.tasks.length,
                ),
              ),
            ),
            const Spacer(),
            _TasksEntranceTransition(
              animation: _entranceController,
              interval: const Interval(0.22, 1.00, curve: Curves.easeOutCubic),
              beginOffset: Offset(-120.w, 0),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 51.w, bottom: 49.h),
                child: Row(
                  children: [
                    PremiumActionButton(iconAsset: AppAssets.premium, text: 'Прокачать', onPressed: widget.onPurchasePremium),
                    SizedBox(width: 50.w),
                    const UpgradeHintText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TasksEntranceTransition extends StatelessWidget {
  const _TasksEntranceTransition({required this.animation, required this.interval, required this.beginOffset, required this.child});

  final Animation<double> animation;
  final Interval interval;
  final Offset beginOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        final progress = interval.transform(animation.value);
        final offset = Offset.lerp(beginOffset, Offset.zero, progress)!;

        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(offset: offset, child: child),
        );
      },
    );
  }
}
