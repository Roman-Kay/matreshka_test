import 'battle_pass_level.dart';

final class BattlePassSeason {
  const BattlePassSeason({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.maxLevel,
    required this.levels,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final int maxLevel;
  final List<BattlePassLevel> levels;

  BattlePassSeason copyWith({
    String? id,
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    int? maxLevel,
    List<BattlePassLevel>? levels,
  }) {
    return BattlePassSeason(
      id: id ?? this.id,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      maxLevel: maxLevel ?? this.maxLevel,
      levels: levels ?? this.levels,
    );
  }
}
