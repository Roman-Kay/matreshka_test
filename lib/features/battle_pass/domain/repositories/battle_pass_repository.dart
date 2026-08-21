import '../models/battle_pass_models.dart';

abstract interface class BattlePassRepository {
  Future<BattlePass> load(BattlePassDemoMode mode);
}
