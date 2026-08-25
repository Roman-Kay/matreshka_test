import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/painters/parallelogram_painter.dart';
import '../../../../pause/domain/models/player_battle_pass_progress.dart';
import '../../../domain/models/battle_pass_models.dart';
import '../../cubit/battle_pass_state.dart';
import 'reward_card.dart';
import 'reward_details_sheet.dart';
import 'reward_rarity_style.dart';

class RewardRail extends StatefulWidget {
  const RewardRail({
    super.key,
    required this.state,
    required this.onSelectReward,
    required this.onClaimReward,
  });

  final BattlePassState state;
  final ValueChanged<int> onSelectReward;
  final ValueChanged<int> onClaimReward;

  @override
  State<RewardRail> createState() => _RewardRailState();
}

class _RewardRailState extends State<RewardRail>
    with SingleTickerProviderStateMixin {
  static const double _railSideInset = 51;
  static const double _railTrailingInset = 100;
  static const double _finalRailTrailingInset = 200;
  static const double _railListPadding = 100;
  static const double _rewardItemExtent = 242;
  static const double _premiumPreviewExtent = 596;
  static const double _premiumPanelReservedWidth = 335;
  static const double _trailingReleaseLookaheadItems = 1;
  static const double _pinnedPrizeDockingOffset = 24;
  static const double _pinnedPrizeRightInset = 56;
  static const double _heldScrollSpeed = 1450;

  late final ScrollController _scrollController;
  late final AnimationController _availableRewardGlowController;
  double _scrollOffset = 0;
  int _scrollDirection = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _availableRewardGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _availableRewardGlowController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final nextOffset = _scrollController.offset;
    if (_scrollOffset == nextOffset) return;
    _scrollDirection = nextOffset > _scrollOffset ? 1 : -1;
    _scrollOffset = nextOffset;
  }

  void _scrollByCards(int direction) {
    if (!_scrollController.hasClients) return;
    final target =
        (_scrollController.offset + direction * 4 * _rewardItemExtent.h).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _startHeldScroll(int direction) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = direction > 0 ? position.maxScrollExtent : 0.0;
    final distance = (target - position.pixels).abs();
    if (distance <= 0.5) return;

    _scrollController.animateTo(
      target,
      duration: Duration(
        milliseconds: max(120, (distance / _heldScrollSpeed * 1000).round()),
      ),
      curve: Curves.linear,
    );
  }

  void _stopHeldScroll() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    final pass = widget.state.battlePass!;
    final levels = pass.season.levels;
    final premiumLocked = pass.premiumStatus == PremiumStatus.locked;
    final visibleEndLevel = _visibleEndLevel(
      pass.progress,
      pass.season.maxLevel,
      premiumLocked,
    );
    final nextUnlockThreshold = _nextUnlockThreshold(
      pass.progress,
      pass.season.maxLevel,
    );
    final visibleLevels = levels
        .where((level) => level.number <= visibleEndLevel)
        .toList(growable: false);
    final railItems = _railItems(
      visibleLevels,
      premiumLocked,
      nextUnlockThreshold,
      visibleEndLevel,
    );

    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = _RailLayoutMetrics.fromViewport(
              viewportWidth: constraints.maxWidth,
              pinnedPrizeRightInset: _pinnedPrizeRightInset.h,
              rewardItemExtent: _rewardItemExtent.h,
              premiumPanelReservedWidth: _premiumPanelReservedWidth.h,
            );
            final shouldReleaseTrailingSpace =
                _shouldReleaseTrailingSpace() ||
                _isAtFinalRewardEnd(
                  premiumLocked,
                  visibleEndLevel,
                  pass.season.maxLevel,
                  constraints.maxWidth,
                );
            final isAtScrollEnd =
                _isAtScrollEnd() || shouldReleaseTrailingSpace;
            final isAtLeadingEdge = _scrollOffset <= 0.5;

            // Каждый 10-й уровень показывает большую награду у премиум-панели.
            // Когда настоящая карточка доезжает до нее, закрепленная копия
            // плавно встраивается в скрол
            final pinnedPrize = _pinnedPrize(
              visibleLevels,
              layout.listDockLeft,
              layout.listViewportRight,
              premiumLocked,
            );
            final pinnedPrizeReward = pinnedPrize == null
                ? null
                : _bigPrizeReward(pinnedPrize.level);
            final pinnedLeft = pinnedPrize == null
                ? layout.pinLeft
                : _pinnedPrizeLeft(
                    pinnedPrize.level.number,
                    layout.pinLeft,
                    premiumLocked,
                    pinnedPrize.dockingProgress,
                  );
            final scrollButtonTop = 68.h;
            final leftScrollButtonLeft = 51.h;
            final showingSeasonEnd = visibleEndLevel >= pass.season.maxLevel;
            final effectiveRailRightInset = shouldReleaseTrailingSpace
                ? 0.0
                : _premiumPanelReservedWidth.h;
            final effectiveListTrailingPadding = shouldReleaseTrailingSpace
                ? showingSeasonEnd
                      ? _finalRailTrailingInset.w
                      : 0.0
                : _railTrailingInset.h;

            return Stack(
              children: [
                Positioned.fill(
                  right: effectiveRailRightInset,
                  left: _railSideInset.h,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x00000000),
                          Color(0xFF000000),
                          Color(0xFF000000),
                          Color(0x00000000),
                        ],
                        stops: [0.00, 0.12, 0.88, 0.97],
                        tileMode: TileMode.clamp,
                      ).createShader(bounds);
                    },
                    child: ClipRect(
                      clipper: const _RailGlowClipper(
                        leftInset: 1,
                        rightInset: 0,
                        verticalOverflow: 96,
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        clipBehavior: Clip.none,
                        padding: EdgeInsets.fromLTRB(
                          _railListPadding.h,
                          0,
                          effectiveListTrailingPadding,
                          0,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: railItems.length,
                        itemBuilder: (context, index) {
                          final item = railItems[index];
                          if (item.isPremiumPreview) {
                            // При закрытом премиуме скрол начинается с превью:
                            return _PremiumPreview(
                              rewards: pass.season.instantPremiumRewards,
                              selectedRewardId: widget.state.selectedRewardId,
                              onSelectReward: widget.onSelectReward,
                            );
                          }

                          final gate = item.gateAfterLevel;
                          if (gate != null) {
                            // Уровни за пределами видимой зоны показываем одной карточкой-заглушкой
                            // и коротким продолжением дороги.
                            return _LockedFutureLevelsPreview(
                              afterLevel: gate,
                              roadFromLevel: item.roadFromLevel!,
                              roadToLevel: item.roadToLevel!,
                              premiumLocked: premiumLocked,
                            );
                          }

                          final level = item.level!;
                          final levelIndex = levels.indexOf(level);
                          final reward = _rewardForLevel(
                            level,
                            widget.state.selectedRewardId,
                          );
                          final rewardStatus = pass.rewardStatus(reward.id);
                          final isLastSeasonLevel =
                              showingSeasonEnd &&
                              level.number >= pass.season.maxLevel;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              RewardCard(
                                level: level.number,
                                reward: reward,
                                rewardStatus: rewardStatus,
                                selected:
                                    widget.state.selectedRewardId == reward.id,
                                progress: pass.progress,
                                isFirstLevel: levelIndex == 0,
                                isLastLevel: false,
                                onSelected: () =>
                                    widget.onSelectReward(reward.id),
                                onClaim: () => widget.onClaimReward(reward.id),
                                onShowDetails: () => _showRewardDetails(
                                  context: context,
                                  reward: reward,
                                  choiceRewards: level.premiumRewards.length > 1
                                      ? level.premiumRewards
                                      : const [],
                                  rewardStatus: rewardStatus,
                                  level: level.number,
                                  premiumStatus: pass.premiumStatus,
                                ),
                                availableGlowAnimation:
                                    _availableRewardGlowController,
                              ),
                              if (!isLastSeasonLevel)
                                Positioned(
                                  right: -5.h,
                                  top: 184.h / 2,
                                  child: SvgPicture.asset(
                                    AppAssets.arrowRoad,
                                    width: 12.h,
                                    height: 20.h,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: pinnedLeft,
                  top: 0,
                  child: IgnorePointer(
                    ignoring: pinnedPrize == null || isAtScrollEnd,
                    child: AnimatedOpacity(
                      opacity: isAtScrollEnd ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        reverseDuration: const Duration(milliseconds: 140),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: pinnedPrize == null || pinnedPrizeReward == null
                            ? SizedBox(
                                key: const ValueKey('empty-big-prize'),
                                width: 242.h,
                                height: 280.h,
                              )
                            : _PinnedBigPrizeCard(
                                key: ValueKey(
                                  'big-prize-${pinnedPrize.level.number}',
                                ),
                                level: pinnedPrize.level.number,
                                reward: pinnedPrizeReward,
                                selected:
                                    widget.state.selectedRewardId ==
                                    pinnedPrizeReward.id,
                                progress: pass.progress,
                                rewardStatus: pass.rewardStatus(
                                  pinnedPrizeReward.id,
                                ),
                                premiumStatus: pass.premiumStatus,
                                dockingProgress: pinnedPrize.dockingProgress,
                                onSelectReward: widget.onSelectReward,
                                onClaimReward: widget.onClaimReward,
                                availableGlowAnimation:
                                    _availableRewardGlowController,
                              ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: leftScrollButtonLeft,
                  top: scrollButtonTop,
                  child: IgnorePointer(
                    ignoring: isAtLeadingEdge,
                    child: AnimatedOpacity(
                      opacity: isAtLeadingEdge ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: _RailScrollButton(
                        direction: AxisDirection.left,
                        onTap: () => _scrollByCards(-1),
                        onHoldStart: () => _startHeldScroll(-1),
                        onHoldEnd: _stopHeldScroll,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 334.h,
                  top: scrollButtonTop,
                  child: IgnorePointer(
                    ignoring: isAtScrollEnd,
                    child: AnimatedOpacity(
                      opacity: isAtScrollEnd ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: _RailScrollButton(
                        direction: AxisDirection.right,
                        onTap: () => _scrollByCards(1),
                        onHoldStart: () => _startHeldScroll(1),
                        onHoldEnd: _stopHeldScroll,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Последний уровень, который нужно отрисовать настоящей карточкой награды.
  ///
  /// Без премиума виден короткий участок и заглушка. С купленным премиумом
  /// показываем больший диапазон вперед, а на максимальном уровне — всю рельсу.
  int _visibleEndLevel(
    PlayerBattlePassProgress progress,
    int maxLevel,
    bool premiumLocked,
  ) {
    if (progress.currentLevel < 100) {
      return min(premiumLocked ? 100 : 119, maxLevel);
    }
    return min(((progress.currentLevel ~/ 20) + 2) * 20, maxLevel);
  }

  int? _nextUnlockThreshold(PlayerBattlePassProgress progress, int maxLevel) {
    final threshold = progress.currentLevel < 100
        ? 100
        : ((progress.currentLevel ~/ 20) + 1) * 20;
    return threshold < maxLevel ? threshold : null;
  }

  /// Превращает видимые уровни в элементы ListView: превью премиума,
  /// карточки наград и, если нужно, заглушку будущих уровней.
  List<_RailItem> _railItems(
    List<BattlePassLevel> levels,
    bool premiumLocked,
    int? nextUnlockThreshold,
    int visibleEndLevel,
  ) {
    final items = <_RailItem>[
      if (premiumLocked) const _RailItem.premiumPreview(),
    ];

    for (final level in levels) {
      items.add(_RailItem.level(level));
    }

    if (nextUnlockThreshold != null) {
      items.add(
        _RailItem.gate(
          afterLevel: nextUnlockThreshold,
          roadFromLevel: visibleEndLevel + 1,
          roadToLevel: _futureRoadToLevel(visibleEndLevel),
        ),
      );
    }

    return items;
  }

  /// Считает, до какого уровня должна тянуться фейковая дорога после заглушки.
  int _futureRoadToLevel(int visibleEndLevel) {
    return visibleEndLevel % 20 == 0
        ? visibleEndLevel + 20
        : visibleEndLevel + 21;
  }

  double _levelTrackLeft(bool premiumLocked) {
    return _railSideInset.h +
        _railListPadding.h +
        (premiumLocked ? _premiumPreviewExtent.h : 0);
  }

  /// Левая координата карточки уровня во viewport до логики закрепления.
  double _bigPrizeLeftInViewport(bool premiumLocked, int level) {
    return _levelTrackLeft(premiumLocked) +
        (level - 1) * _rewardItemExtent.h -
        _scrollOffset;
  }

  bool _isAtScrollEnd() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.extentAfter <= 0.5;
  }

  bool _shouldReleaseTrailingSpace() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.extentAfter <=
        _premiumPanelReservedWidth.h +
            _railTrailingInset.h +
            _rewardItemExtent.h * _trailingReleaseLookaheadItems;
  }

  /// Последняя настоящая награда может закончиться раньше maxScrollExtent,
  /// потому что справа зарезервировано место под премиум-панель.
  bool _isAtFinalRewardEnd(
    bool premiumLocked,
    int visibleEndLevel,
    int maxLevel,
    double viewportWidth,
  ) {
    if (visibleEndLevel < maxLevel) return false;
    final lastRewardRight =
        _bigPrizeLeftInViewport(premiumLocked, visibleEndLevel) +
        _rewardItemExtent.h;
    return lastRewardRight <= viewportWidth - _railTrailingInset.h + 0.5;
  }

  /// Плавно переводит большую закрепленную награду из боковой позиции в рельсу.
  double _pinnedPrizeLeft(
    int level,
    double pinLeft,
    bool premiumLocked,
    double dockingProgress,
  ) {
    if (dockingProgress <= 0) return pinLeft;
    final targetLeft =
        _bigPrizeLeftInViewport(premiumLocked, level) +
        _pinnedPrizeDockingOffset.h;
    final easedProgress = Curves.easeOutCubic.transform(dockingProgress);
    return pinLeft + (targetLeft - pinLeft) * easedProgress;
  }

  /// Возвращает следующий уровень с большой наградой для закрепления или въезда.
  _PinnedPrize? _pinnedPrize(
    List<BattlePassLevel> levels,
    double pinLeft,
    double listViewportRight,
    bool premiumLocked,
  ) {
    final cardWidth = _rewardItemExtent.h;
    final dockingStartLeft = listViewportRight + cardWidth * 0.5;
    final dockingEndLeft = listViewportRight - cardWidth;
    final dockingDistance = dockingStartLeft - dockingEndLeft;
    for (final level in levels) {
      if (level.number % 10 != 0) continue;
      final levelLeft = _bigPrizeLeftInViewport(premiumLocked, level.number);
      final isDocking =
          _scrollDirection > 0 &&
          levelLeft <= dockingStartLeft &&
          levelLeft >= dockingEndLeft;

      if (isDocking) {
        final rawProgress = ((dockingStartLeft - levelLeft) / dockingDistance)
            .clamp(0, 1)
            .toDouble();
        return _PinnedPrize(level: level, dockingProgress: rawProgress);
      }

      if (levelLeft > dockingStartLeft) {
        return _PinnedPrize(level: level, dockingProgress: 0);
      }
    }
    return null;
  }

  BattlePassReward _bigPrizeReward(BattlePassLevel level) {
    for (final reward in level.premiumRewards) {
      if (reward.type == RewardType.vehicle ||
          reward.rarity == RewardRarity.legendary) {
        return reward;
      }
    }
    if (level.premiumRewards.isNotEmpty) return level.premiumRewards.first;
    return level.freeRewards.first;
  }

  BattlePassReward _rewardForLevel(BattlePassLevel level, int? selectedId) {
    final rewards = [...level.freeRewards, ...level.premiumRewards];
    for (final reward in rewards) {
      if (reward.id == selectedId) return reward;
    }

    if (level.number.isOdd && level.freeRewards.isNotEmpty) {
      return level.freeRewards.first;
    }
    if (level.premiumRewards.isNotEmpty) return level.premiumRewards.first;
    return level.freeRewards.first;
  }

  void _showRewardDetails({
    required BuildContext context,
    required BattlePassReward reward,
    required List<BattlePassReward> choiceRewards,
    required RewardStatus rewardStatus,
    required int level,
    required PremiumStatus premiumStatus,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ink,
      builder: (_) => RewardDetailsSheet(
        reward: reward,
        rewardStatus: rewardStatus,
        choiceRewards: choiceRewards,
        level: level,
        premiumStatus: premiumStatus,
        onClaim: () => widget.onClaimReward(reward.id),
      ),
    );
  }
}

class _PremiumPreview extends StatelessWidget {
  const _PremiumPreview({
    required this.rewards,
    required this.selectedRewardId,
    required this.onSelectReward,
  });

  final List<BattlePassReward> rewards;
  final int? selectedRewardId;
  final ValueChanged<int> onSelectReward;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              SizedBox(
                height: 220.h,
                child: Row(
                  children: [
                    for (final reward in rewards)
                      InkWell(
                        onTap: () => onSelectReward(reward.id),
                        borderRadius: BorderRadius.circular(18.h),
                        child: Center(
                          child: RewardCardVisual(
                            reward: reward,
                            selected: selectedRewardId == reward.id,
                            available: false,
                            received: false,
                            largeSize: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(right: 23.h),
                child: const _PremiumPreviewButton(),
              ),
            ],
          ),
          Positioned(
            right: -12.h,
            top: 184.h / 2,
            child: SvgPicture.asset(
              AppAssets.arrowRoad,
              width: 12.h,
              height: 20.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumPreviewButton extends StatelessWidget {
  const _PremiumPreviewButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 596.h,
      height: 60.h,
      child: CustomPaint(
        painter: ParallelogramPainter(
          fillColors: const [
            Color(0x996B3108),
            Color(0x996B3108),
            Color(0x996B3108),
          ],
          borderColor: AppColors.transparent,
          borderWidth: 0,
          skew: 12.h,
          radius: 20.h,
        ),
        child: Center(
          child: Text(
            'Получи все сразу!',
            style: TextStyle(
              color: const Color(0xFFFFD149),
              fontSize: 30.h,
              fontFamily: 'Geologica Roman',
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.30.h,
              shadows: [
                Shadow(
                  offset: Offset(0, 0),
                  blurRadius: 14,
                  color: Color(0xFFFF5C00).withValues(alpha: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedFutureLevelsPreview extends StatelessWidget {
  const _LockedFutureLevelsPreview({
    required this.afterLevel,
    required this.roadFromLevel,
    required this.roadToLevel,
    required this.premiumLocked,
  });

  final int afterLevel;
  final int roadFromLevel;
  final int roadToLevel;
  final bool premiumLocked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 760.h,
      height: 300.h,
      child: Stack(
        children: [
          Positioned(
            left: 28.h,
            top: 18.h,
            child: SizedBox(
              width: 520.h,
              height: 184.h,
              child: CustomPaint(
                painter: ParallelogramPainter(
                  fillColors: const [
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x00000000),
                  ],
                  borderColor: const Color(0x33E9E9F3),
                  borderWidth: 4.h,
                  skew: 28.h,
                  radius: 24.h,
                ),
                child: Center(
                  child: SizedBox(
                    width: 400.h,
                    child: premiumLocked
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Награды 100+ уровней доступны только\nс ',
                                  style: TextStyle(
                                    color: AppColors.white60,
                                    fontSize: 26.h,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26.h,
                                  ),
                                ),
                                TextSpan(
                                  text: 'прокачкой',
                                  style: TextStyle(
                                    color: AppColors.white100,
                                    fontSize: 26.h,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26.h,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Награды откроются после прохождения ',
                                  style: TextStyle(
                                    color: AppColors.white60,
                                    fontSize: 26.h,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26.h,
                                  ),
                                ),
                                TextSpan(
                                  text: '$afterLevel уровня',
                                  style: TextStyle(
                                    color: AppColors.white100,
                                    fontSize: 26.h,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26.h,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 34.h,
            child: _FutureLevelsRoad(
              fromLevel: roadFromLevel,
              toLevel: roadToLevel,
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureLevelsRoad extends StatelessWidget {
  const _FutureLevelsRoad({required this.fromLevel, required this.toLevel});

  final int fromLevel;
  final int toLevel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 760.h,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            width: 121.h,
            child: Container(height: 10.h, color: AppColors.background10),
          ),
          Positioned(
            left: 76.h,
            child: _FutureLevelMarker(level: fromLevel),
          ),
          Positioned(
            left: 144.h,
            child: Image.asset(
              AppAssets.dotedLine,
              width: 196.h,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 318.h,
            child: _FutureLevelMarker(level: toLevel),
          ),
        ],
      ),
    );
  }
}

class _FutureLevelMarker extends StatelessWidget {
  const _FutureLevelMarker({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.h,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 45.h,
              height: 45.h,
              decoration: BoxDecoration(
                color: AppColors.background10,
                borderRadius: BorderRadius.circular(8.h),
              ),
            ),
          ),
          Text(
            '$level',
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 22.h,
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.22.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailScrollButton extends StatelessWidget {
  const _RailScrollButton({
    required this.direction,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final AxisDirection direction;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      AppAssets.arrowLeft,
      width: 36.h,
      height: 36.h,
    );
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onHoldStart(),
      onLongPressEnd: (_) => onHoldEnd(),
      onLongPressCancel: onHoldEnd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 84.h,
        height: 84.h,
        padding: EdgeInsets.all(24.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.h),
          ),
        ),
        child: direction == AxisDirection.right
            ? Transform.rotate(angle: pi, child: icon)
            : icon,
      ),
    );
  }
}

final class _PinnedPrize {
  const _PinnedPrize({required this.level, required this.dockingProgress});

  final BattlePassLevel level;
  final double dockingProgress;
}

final class _RailLayoutMetrics {
  const _RailLayoutMetrics({
    required this.pinLeft,
    required this.listDockLeft,
    required this.listViewportRight,
  });

  factory _RailLayoutMetrics.fromViewport({
    required double viewportWidth,
    required double pinnedPrizeRightInset,
    required double rewardItemExtent,
    required double premiumPanelReservedWidth,
  }) {
    return _RailLayoutMetrics(
      pinLeft: viewportWidth - pinnedPrizeRightInset - rewardItemExtent,
      listDockLeft:
          viewportWidth - premiumPanelReservedWidth - rewardItemExtent,
      listViewportRight: viewportWidth - premiumPanelReservedWidth,
    );
  }

  final double pinLeft;
  final double listDockLeft;
  final double listViewportRight;
}

class _RailGlowClipper extends CustomClipper<Rect> {
  const _RailGlowClipper({
    required this.leftInset,
    required this.rightInset,
    required this.verticalOverflow,
  });

  final double leftInset;
  final double rightInset;
  final double verticalOverflow;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      leftInset,
      -verticalOverflow,
      size.width - rightInset,
      size.height + verticalOverflow,
    );
  }

  @override
  bool shouldReclip(_RailGlowClipper oldClipper) {
    return oldClipper.leftInset != leftInset ||
        oldClipper.rightInset != rightInset ||
        oldClipper.verticalOverflow != verticalOverflow;
  }
}

final class _RailItem {
  const _RailItem._({
    this.level,
    this.gateAfterLevel,
    this.roadFromLevel,
    this.roadToLevel,
    this.isPremiumPreview = false,
  });

  const _RailItem.premiumPreview() : this._(isPremiumPreview: true);

  const _RailItem.level(BattlePassLevel level) : this._(level: level);

  const _RailItem.gate({
    required int afterLevel,
    required int roadFromLevel,
    required int roadToLevel,
  }) : this._(
         gateAfterLevel: afterLevel,
         roadFromLevel: roadFromLevel,
         roadToLevel: roadToLevel,
       );

  final BattlePassLevel? level;
  final int? gateAfterLevel;
  final int? roadFromLevel;
  final int? roadToLevel;
  final bool isPremiumPreview;
}

class _PinnedBigPrizeCard extends StatelessWidget {
  const _PinnedBigPrizeCard({
    super.key,
    required this.level,
    required this.reward,
    required this.rewardStatus,
    required this.selected,
    required this.progress,
    required this.premiumStatus,
    required this.dockingProgress,
    required this.onSelectReward,
    required this.onClaimReward,
    required this.availableGlowAnimation,
  });

  final int level;
  final BattlePassReward reward;
  final RewardStatus rewardStatus;
  final bool selected;
  final PlayerBattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final double dockingProgress;
  final ValueChanged<int> onSelectReward;
  final ValueChanged<int> onClaimReward;
  final Animation<double> availableGlowAnimation;

  @override
  Widget build(BuildContext context) {
    final shouldDockIntoLargeRailCard = rewardStatus == RewardStatus.available;
    final dockingScale = shouldDockIntoLargeRailCard
        ? 1.0
        : 1 - dockingProgress * 0.16;
    final dockingOpacity = dockingProgress < 0.55
        ? 1.0
        : (1 - (dockingProgress - 0.55) / 0.45).clamp(0, 1).toDouble();

    return Opacity(
      opacity: dockingOpacity,
      child: RewardCard(
        level: level,
        reward: reward,
        rewardStatus: rewardStatus,
        selected: selected,
        progress: progress,
        isFirstLevel: false,
        isLastLevel: false,
        onSelected: () => onSelectReward(reward.id),
        onClaim: () => onClaimReward(reward.id),
        onShowDetails: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: AppColors.ink,
          builder: (_) => RewardDetailsSheet(
            reward: reward,
            rewardStatus: rewardStatus,
            choiceRewards: const [],
            level: level,
            premiumStatus: premiumStatus,
            onClaim: () => onClaimReward(reward.id),
          ),
        ),
        showRoadLines: false,
        forceLargeSize: true,
        visualScale: dockingScale,
        availableGlowAnimation: availableGlowAnimation,
        staticGlowColor: reward.rarity.gradientColors.last,
      ),
    );
  }
}
