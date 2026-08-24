import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/ui/buttons/premium_action_button.dart';
import '../../domain/models/task.dart';
import '../models/tasks_progress_summary.dart';
import 'task_card.dart';
import 'tasks_header.dart';
import 'upgrade_hint_text.dart';

class TasksContent extends StatelessWidget {
  const TasksContent({
    super.key,
    this.progress,
    required this.tasks,
    this.onBack,
    this.onExit,
    this.onPurchasePremium,
  });

  final TasksProgressSummary? progress;
  final List<Task> tasks;
  final VoidCallback? onBack;
  final VoidCallback? onExit;
  final VoidCallback? onPurchasePremium;

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
          child: TasksHeader(
            progress: progress,
            onBack: onBack,
            onExit: onExit,
          ),
        ),
        Positioned.fill(
          top: 148.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 52.w),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => TaskCard(task: tasks[index]),
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
                onPressed: onPurchasePremium,
              ),
              SizedBox(width: 52.w),
              const UpgradeHintText(),
            ],
          ),
        ),
      ],
    );
  }
}
