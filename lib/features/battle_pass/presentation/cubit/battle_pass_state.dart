import '../../domain/models/battle_pass_models.dart';

enum BattlePassViewStatus { initial, loading, loaded, failure }

final class BattlePassState {
  const BattlePassState({
    required this.status,
    required this.demoMode,
    this.battlePass,
    this.selectedRewardId,
    this.message,
  });

  const BattlePassState.initial()
    : status = BattlePassViewStatus.initial,
      demoMode = BattlePassDemoMode.premiumLocked,
      battlePass = null,
      selectedRewardId = null,
      message = null;

  final BattlePassViewStatus status;
  final BattlePassDemoMode demoMode;
  final BattlePass? battlePass;
  final int? selectedRewardId;
  final String? message;

  BattlePassState copyWith({
    BattlePassViewStatus? status,
    BattlePassDemoMode? demoMode,
    BattlePass? battlePass,
    int? selectedRewardId,
    String? message,
    bool clearMessage = false,
  }) {
    return BattlePassState(
      status: status ?? this.status,
      demoMode: demoMode ?? this.demoMode,
      battlePass: battlePass ?? this.battlePass,
      selectedRewardId: selectedRewardId ?? this.selectedRewardId,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
