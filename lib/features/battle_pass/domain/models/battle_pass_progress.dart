final class BattlePassProgress {
  const BattlePassProgress({
    required this.currentLevel,
    required this.currentXp,
    required this.nextLevelXp,
  });

  final int currentLevel;
  final int currentXp;
  final int nextLevelXp;

  double get ratio {
    if (nextLevelXp <= 0) return 1;
    return (currentXp / nextLevelXp).clamp(0, 1);
  }

  BattlePassProgress copyWith({
    int? currentLevel,
    int? currentXp,
    int? nextLevelXp,
  }) {
    return BattlePassProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
    );
  }
}
