import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../tasks/domain/models/task.dart';
import 'task_preview_action_button.dart';
import 'task_preview_header.dart';
import 'task_preview_progress_segments.dart';

class TasksPreview extends StatefulWidget {
  const TasksPreview({
    super.key,
    required this.tasks,
    required this.onTap,
    required this.onClaim,
  });

  final List<Task> tasks;
  final VoidCallback onTap;
  final ValueChanged<int> onClaim;

  @override
  State<TasksPreview> createState() => _TasksPreviewState();
}

class _TasksPreviewState extends State<TasksPreview> {
  late final PageController _textPageController;
  late final ValueNotifier<int> _activeIndex;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _textPageController = PageController();
    _activeIndex = ValueNotifier<int>(0);
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.tasks.length < 2) return;
      final nextIndex = (_activeIndex.value + 1) % widget.tasks.length;
      if (!_textPageController.hasClients) {
        _activeIndex.value = nextIndex;
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
    _activeIndex.dispose();
    _textPageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TasksPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks.isEmpty) return;
    if (_activeIndex.value >= widget.tasks.length) {
      _activeIndex.value = widget.tasks.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    if (tasks.isEmpty) return const SizedBox.shrink();

    return ValueListenableBuilder<int>(
      valueListenable: _activeIndex,
      builder: (context, activeIndex, child) {
        final activeTask = tasks[activeIndex];

        return Padding(
          padding: EdgeInsets.only(left: 61.r, top: 59.r),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -120) _goToTask(activeIndex + 1);
              if (velocity > 120) _goToTask(activeIndex - 1);
            },
            child: SizedBox(
              width: 400.r,
              child: Column(
                children: [
                  Container(
                    height: 110.r,
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
                      child: TaskPreviewHeader(
                        key: ValueKey('header-${tasks[activeIndex].id}'),
                        task: tasks[activeIndex],
                        taskIndex: activeIndex,
                        taskCount: tasks.length,
                      ),
                    ),
                  ),
                  Container(
                    height: 290.r,
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
                          width: 320.r,
                          height: 54.r,
                          child: PageView.builder(
                            controller: _textPageController,
                            itemCount: tasks.length,
                            onPageChanged: (index) =>
                                _activeIndex.value = index,
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
                                  fontSize: 22.r,
                                  fontWeight: FontWeight.w500,
                                  height: 1.20,
                                  letterSpacing: -0.22.r,
                                ),
                              );
                            },
                          ),
                        ),
                        const Spacer(flex: 50),
                        TaskPreviewProgressSegments(
                          count: tasks.length,
                          activeIndex: activeIndex,
                        ),
                        SizedBox(height: 26.r),
                        TaskPreviewActionButton(
                          task: activeTask,
                          onOpenTasks: widget.onTap,
                          onClaim: () => widget.onClaim(activeTask.id),
                        ),
                        SizedBox(height: 36.r),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToTask(int index) {
    if (widget.tasks.isEmpty) return;
    final nextIndex = index.clamp(0, widget.tasks.length - 1);
    if (nextIndex == _activeIndex.value) return;

    _activeIndex.value = nextIndex;
    if (!_textPageController.hasClients) return;
    _textPageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}
