import '../../../battle_pass/domain/models/battle_pass_enums.dart';
import '../models/player_battle_pass_state.dart';

abstract interface class PauseProfileRepository {
  Future<PlayerBattlePassState> loadBattlePassState({required BattlePassDemoMode mode});
}
