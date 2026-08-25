final class TasksProgressSummary {
  const TasksProgressSummary({required this.currentLevel, required this.currentXp, required this.nextLevelXp, required this.tasksRefreshAt});

  final int currentLevel;
  final int currentXp;
  final int nextLevelXp;
  final DateTime tasksRefreshAt;

  double get ratio {
    if (nextLevelXp <= 0) return 1;
    return (currentXp / nextLevelXp).clamp(0, 1);
  }
}
