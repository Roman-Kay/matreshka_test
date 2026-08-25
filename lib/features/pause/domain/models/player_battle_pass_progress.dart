final class PlayerBattlePassProgress {
  const PlayerBattlePassProgress({
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

  PlayerBattlePassProgress copyWith({
    int? currentLevel,
    int? currentXp,
    int? nextLevelXp,
  }) {
    return PlayerBattlePassProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
    );
  }
}
