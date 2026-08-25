import '../../../battle_pass/domain/models/battle_pass_enums.dart';

final class PlayerRewardState {
  const PlayerRewardState({
    required this.rewardId,
    required this.status,
    this.receivedAt,
  });

  final int rewardId;
  final RewardStatus status;
  final DateTime? receivedAt;

  PlayerRewardState copyWith({
    RewardStatus? status,
    DateTime? receivedAt,
    bool clearReceivedAt = false,
  }) {
    return PlayerRewardState(
      rewardId: rewardId,
      status: status ?? this.status,
      receivedAt: clearReceivedAt ? null : receivedAt ?? this.receivedAt,
    );
  }
}
