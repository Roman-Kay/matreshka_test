import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/battle_pass_models.dart';
import '../cubit/battle_pass_cubit.dart';
import '../cubit/battle_pass_state.dart';

class RewardRail extends StatefulWidget {
  const RewardRail({super.key, required this.state});

  final BattlePassState state;

  @override
  State<RewardRail> createState() => _RewardRailState();
}

class _RewardRailState extends State<RewardRail> {
  static const double _railSideInset = 51;
  static const double _railTrailingInset = 100;
  static const double _railListPadding = 100;
  static const double _rewardItemExtent = 242;
  static const double _premiumPreviewExtent = 596;
  static const double _premiumPanelReservedWidth = 375;
  static const double _pinnedPrizeRightInset = 56;
  static const double _heldScrollSpeed = 1450;

  late final ScrollController _scrollController;
  double _scrollOffset = 0;
  int _scrollDirection = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final nextOffset = _scrollController.offset;
    if (_scrollOffset == nextOffset) return;
    setState(() {
      _scrollDirection = nextOffset > _scrollOffset ? 1 : -1;
      _scrollOffset = nextOffset;
    });
  }

  void _scrollByCards(int direction) {
    if (!_scrollController.hasClients) return;
    final target =
        (_scrollController.offset + direction * 4 * _rewardItemExtent.w).clamp(
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x553A0A0A),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pinLeft =
              constraints.maxWidth -
              _pinnedPrizeRightInset.w -
              _rewardItemExtent.w;
          final listDockLeft =
              constraints.maxWidth -
              _premiumPanelReservedWidth.w -
              _rewardItemExtent.w;
          final listViewportRight =
              constraints.maxWidth - _premiumPanelReservedWidth.w;
          final isAtScrollEnd =
              _isAtScrollEnd() ||
              _isAtFinalRewardEnd(
                premiumLocked,
                visibleEndLevel,
                pass.season.maxLevel,
                constraints.maxWidth,
              );
          final isAtLeadingEdge = _scrollOffset <= 0.5;
          final pinnedPrize = _pinnedPrize(
            visibleLevels,
            listDockLeft,
            listViewportRight,
            premiumLocked,
          );
          final pinnedPrizeReward = pinnedPrize == null
              ? null
              : _bigPrizeReward(pinnedPrize.level);
          final pinnedLeft = pinnedPrize == null
              ? pinLeft
              : _pinnedPrizeLeft(
                  pinnedPrize.level.number,
                  pinLeft,
                  premiumLocked,
                  pinnedPrize.dockingProgress,
                );
          final scrollButtonTop = 68.h;
          final leftScrollButtonLeft = 51.w;

          return Stack(
            children: [
              Positioned.fill(
                right: isAtScrollEnd
                    ? _railTrailingInset.w
                    : _premiumPanelReservedWidth.w,
                left: _railSideInset.w,
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
                      stops: [0, 0.08, 0.92, 1],
                    ).createShader(bounds);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      _railListPadding.w,
                      0,
                      _railTrailingInset.w,
                      0,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: railItems.length,
                    itemBuilder: (context, index) {
                      final item = railItems[index];
                      if (item.isPremiumPreview) {
                        return _PremiumPreview(
                          rewards: levels
                              .take(3)
                              .map((level) => level.premiumRewards.first)
                              .toList(growable: false),
                        );
                      }

                      final gate = item.gateAfterLevel;
                      if (gate != null) {
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
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          RewardCard(
                            level: level.number,
                            reward: reward,
                            choiceRewards: level.premiumRewards.length > 1
                                ? level.premiumRewards
                                : const [],
                            selected:
                                widget.state.selectedRewardId == reward.id,
                            progress: pass.progress,
                            premiumStatus: pass.premiumStatus,
                            isFirstLevel: levelIndex == 0,
                            isLastLevel: false,
                          ),
                          Positioned(
                            right: -5.w,
                            top: 184.h / 2,
                            child: SvgPicture.asset(
                              AppAssets.arrowRoad,
                              width: 12.w,
                              height: 20.h,
                            ),
                          ),
                        ],
                      );
                    },
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
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: pinnedPrize == null || pinnedPrizeReward == null
                          ? SizedBox(
                              key: const ValueKey('empty-big-prize'),
                              width: 242.w,
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
                              premiumStatus: pass.premiumStatus,
                              dockingProgress: pinnedPrize.dockingProgress,
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
                right: 334.w,
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
      ),
    );
  }

  int _visibleEndLevel(
    BattlePassProgress progress,
    int maxLevel,
    bool premiumLocked,
  ) {
    if (progress.currentLevel < 100) {
      return min(premiumLocked ? 100 : 119, maxLevel);
    }
    return min(((progress.currentLevel ~/ 20) + 2) * 20, maxLevel);
  }

  int? _nextUnlockThreshold(BattlePassProgress progress, int maxLevel) {
    final threshold = progress.currentLevel < 100
        ? 100
        : ((progress.currentLevel ~/ 20) + 1) * 20;
    return threshold < maxLevel ? threshold : null;
  }

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

  int _futureRoadToLevel(int visibleEndLevel) {
    return visibleEndLevel % 20 == 0
        ? visibleEndLevel + 20
        : visibleEndLevel + 21;
  }

  double _levelTrackLeft(bool premiumLocked) {
    return _railSideInset.w +
        _railListPadding.w +
        (premiumLocked ? _premiumPreviewExtent.w : 0);
  }

  double _bigPrizeLeftInViewport(bool premiumLocked, int level) {
    return _levelTrackLeft(premiumLocked) +
        (level - 1) * _rewardItemExtent.w -
        _scrollOffset;
  }

  bool _isAtScrollEnd() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.extentAfter <= 0.5;
  }

  bool _isAtFinalRewardEnd(
    bool premiumLocked,
    int visibleEndLevel,
    int maxLevel,
    double viewportWidth,
  ) {
    if (visibleEndLevel < maxLevel) return false;
    final lastRewardRight =
        _bigPrizeLeftInViewport(premiumLocked, visibleEndLevel) +
        _rewardItemExtent.w;
    return lastRewardRight <= viewportWidth - _railTrailingInset.w + 0.5;
  }

  double _pinnedPrizeLeft(
    int level,
    double pinLeft,
    bool premiumLocked,
    double dockingProgress,
  ) {
    if (dockingProgress <= 0) return pinLeft;
    final targetLeft = _bigPrizeLeftInViewport(premiumLocked, level);
    final easedProgress = Curves.easeOutCubic.transform(dockingProgress);
    return pinLeft + (targetLeft - pinLeft) * easedProgress;
  }

  _PinnedPrize? _pinnedPrize(
    List<BattlePassLevel> levels,
    double pinLeft,
    double listViewportRight,
    bool premiumLocked,
  ) {
    final cardWidth = 242.w;
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
}

class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.level,
    required this.reward,
    required this.choiceRewards,
    required this.selected,
    required this.progress,
    required this.premiumStatus,
    required this.isFirstLevel,
    required this.isLastLevel,
    this.showRoadLines = true,
  });

  final int level;
  final BattlePassReward reward;
  final List<BattlePassReward> choiceRewards;
  final bool selected;
  final BattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final bool isFirstLevel;
  final bool isLastLevel;
  final bool showRoadLines;

  @override
  Widget build(BuildContext context) {
    final unlocked = level <= progress.currentLevel;
    final received = reward.status == RewardStatus.received;
    final available = reward.status == RewardStatus.available;
    final cardWidth = available ? 242.w : 210.w;
    final cardHeight = available ? 220.h : 184.h;
    final borderColor = selected
        ? AppColors.white100
        : available
        ? AppColors.green
        : AppColors.white40;
    final borderWidth = selected || available ? 4.r : 1.r;
    return InkWell(
      onTap: () => context.read<BattlePassCubit>().selectReward(reward.id),
      onLongPress: () => _showDetails(context),
      borderRadius: BorderRadius.circular(18.r),
      child: SizedBox(
        width: 242.w,
        height: 300.h,

        child: Column(
          children: [
            SizedBox(
              height: 220.h,
              width: 242.w,
              child: Center(
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Center(
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: received ? 0.5 : 1,
                          child: TweenAnimationBuilder<Color?>(
                            tween: ColorTween(end: borderColor),
                            duration: const Duration(milliseconds: 180),
                            builder: (context, animatedBorderColor, _) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(end: borderWidth),
                                duration: const Duration(milliseconds: 180),
                                builder: (context, animatedBorderWidth, _) {
                                  return CustomPaint(
                                    painter: _ParallelogramPainter(
                                      fillColors: reward.rarity.gradientColors,
                                      borderColor:
                                          animatedBorderColor ?? borderColor,
                                      borderWidth: animatedBorderWidth,
                                      skew: 26.w,
                                      radius: 24.r,
                                      glowColor: available
                                          ? AppColors.green
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: 18.h,
                                              bottom: 10.h,
                                            ),
                                            child: Image.asset(
                                              reward.assetPath ??
                                                  AppAssets.rewardTwo,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        if (!available)
                                          Positioned(
                                            left: 26.w,
                                            top: 10.h,
                                            child: RewardTrackIcon(
                                              track: reward.track,
                                            ),
                                          ),
                                        if (reward.amount > 1)
                                          Positioned(
                                            right: 28.w,
                                            bottom: available ? 70.h : 12.h,
                                            child: _RewardAmountBadge(
                                              amount: reward.amount,
                                            ),
                                          ),
                                        if (available)
                                          Positioned(
                                            left: 13.w,
                                            bottom: 14.h,
                                            child: _ClaimRewardButton(
                                              onTap: () => context
                                                  .read<BattlePassCubit>()
                                                  .claimReward(reward.id),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (received)
                          Positioned(
                            right: 26.w,
                            top: 24.h,
                            child: SvgPicture.asset(
                              AppAssets.done,
                              width: 62.w,
                              height: 42.h,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 6.h),
            _LevelProgressMarker(
              level: level,
              unlocked: unlocked,
              current: level == progress.currentLevel,
              drawLeftLine: showRoadLines && !isFirstLevel,
              drawRightLine: showRoadLines && !isLastLevel,
              nextUnlocked: level + 1 <= progress.currentLevel,
              levelProgress: progress.ratio + 1,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ink,
      builder: (_) => BlocProvider.value(
        value: context.read<BattlePassCubit>(),
        child: _RewardDetailsSheet(
          reward: reward,
          choiceRewards: choiceRewards,
          level: level,
          premiumStatus: premiumStatus,
        ),
      ),
    );
  }
}

class _ClaimRewardButton extends StatelessWidget {
  const _ClaimRewardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 198.w,
        height: 60.h,
        child: CustomPaint(
          painter: _ParallelogramPainter(
            fillColors: const [
              Color(0xFF56B877),
              Color(0xFF56B877),
              Color(0xFF449660),
            ],
            borderColor: AppColors.transperent,
            borderWidth: 0,
            skew: 9.w,
            radius: 20.r,
          ),
          child: Center(
            child: Text(
              'Забрать',
              style: TextStyle(
                color: AppColors.white100,
                fontSize: 26.sp,
                fontWeight: FontWeight.w500,
                height: 1.20,
                letterSpacing: -0.26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumPreview extends StatelessWidget {
  const _PremiumPreview({required this.rewards});

  final List<BattlePassReward> rewards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 596.w,
      height: 300.h,

      child: Column(
        children: [
          SizedBox(
            height: 220.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final reward in rewards)
                  _PremiumPreviewCard(
                    reward: reward,
                    selected:
                        context
                            .watch<BattlePassCubit>()
                            .state
                            .selectedRewardId ==
                        reward.id,
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          const _PremiumPreviewButton(),
        ],
      ),
    );
  }
}

class _PremiumPreviewCard extends StatelessWidget {
  const _PremiumPreviewCard({required this.reward, required this.selected});

  final BattlePassReward reward;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<BattlePassCubit>().selectReward(reward.id),
      child: SizedBox(
        width: 190.w,
        height: 184.h,
        child: CustomPaint(
          painter: _ParallelogramPainter(
            fillColors: reward.rarity.gradientColors,
            borderColor: selected ? AppColors.white100 : AppColors.white40,
            borderWidth: selected ? 4.r : 1.r,
            skew: 24.w,
            radius: 24.r,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 14.w,
                top: 10.h,
                child: RewardTrackIcon(track: reward.track),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 28.h, 18.w, 20.h),
                  child: Image.asset(
                    reward.assetPath ?? AppAssets.rewardOne,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (reward.amount > 1)
                Positioned(
                  right: 14.w,
                  bottom: 12.h,
                  child: _RewardAmountBadge(amount: reward.amount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPreviewButton extends StatelessWidget {
  const _PremiumPreviewButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 596.w,
      height: 60.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x996B3108),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            'Получи все сразу!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFFD149),
              fontSize: 30.sp,
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.30,
              shadows: const [
                Shadow(
                  offset: Offset.zero,
                  blurRadius: 14,
                  color: Color(0xFFFF5C00),
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
      width: 760.w,
      height: 300.h,
      child: Stack(
        children: [
          Positioned(
            left: 28.w,
            top: 26.h,
            child: SizedBox(
              width: 520.w,
              height: 184.h,
              child: CustomPaint(
                painter: _ParallelogramPainter(
                  fillColors: const [
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x00000000),
                  ],
                  borderColor: const Color(0x33E9E9F3),
                  borderWidth: 4.r,
                  skew: 28.w,
                  radius: 24.r,
                ),
                child: Center(
                  child: SizedBox(
                    width: 400.w,
                    child: premiumLocked
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Награды 100+ уровней доступны только\nс ',
                                  style: TextStyle(
                                    color: AppColors.white60,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26,
                                  ),
                                ),
                                TextSpan(
                                  text: 'прокачкой',
                                  style: TextStyle(
                                    color: AppColors.white100,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26,
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
                                  text: 'Награды откроются после прохождения',
                                  style: TextStyle(
                                    color: AppColors.white60,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ',
                                  style: TextStyle(
                                    color: const Color(0xE5E9E9F3),
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26,
                                  ),
                                ),
                                TextSpan(
                                  text: '$afterLevel уровня',
                                  style: TextStyle(
                                    color: AppColors.white100,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.20,
                                    letterSpacing: -0.26,
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
            bottom: 14.h,
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
      width: 760.w,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            width: 121.w,
            child: Container(height: 10.h, color: AppColors.background10),
          ),
          Positioned(
            left: 76.w,
            child: _FutureLevelMarker(level: fromLevel),
          ),
          Positioned(
            left: 162.w,
            child: Image.asset(
              AppAssets.dotedLine,
              width: 160.w,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 318.w,
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
      width: 90.w,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 45.r,
              height: 45.r,
              decoration: BoxDecoration(
                color: AppColors.background10,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Text(
            '$level',
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.22,
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
      width: 36.r,
      height: 36.r,
    );
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onHoldStart(),
      onLongPressEnd: (_) => onHoldEnd(),
      onLongPressCancel: onHoldEnd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 84.r,
        height: 84.r,
        padding: EdgeInsets.all(24.r),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
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
    required this.selected,
    required this.progress,
    required this.premiumStatus,
    required this.dockingProgress,
  });

  final int level;
  final BattlePassReward reward;
  final bool selected;
  final BattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final double dockingProgress;

  @override
  Widget build(BuildContext context) {
    final sameSizeAsRailCard = reward.status == RewardStatus.available;
    final dockingScale = sameSizeAsRailCard ? 1.0 : 1 - dockingProgress * 0.16;
    final dockingOpacity = dockingProgress < 0.55
        ? 1.0
        : (1 - (dockingProgress - 0.55) / 0.45).clamp(0, 1).toDouble();

    return Opacity(
      opacity: dockingOpacity,
      child: Transform.scale(
        scale: dockingScale,
        alignment: Alignment.center,
        child: RewardCard(
          level: level,
          reward: reward,
          choiceRewards: const [],
          selected: selected,
          progress: progress,
          premiumStatus: premiumStatus,
          isFirstLevel: false,
          isLastLevel: false,
          showRoadLines: false,
        ),
      ),
    );
  }
}

class _ChoiceRewardTitle extends StatelessWidget {
  const _ChoiceRewardTitle({required this.rewards});

  final List<BattlePassReward> rewards;

  @override
  Widget build(BuildContext context) {
    final firstTitle = rewards.first.title;
    final secondTitle = rewards.length > 1 ? rewards[1].title : '';
    final titleStyle = TextStyle(
      color: AppColors.white100,
      fontSize: 36.sp,
      fontWeight: FontWeight.w600,
      height: 1.30,
      letterSpacing: -0.36,
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.w,
        children: [
          Text(firstTitle, textAlign: TextAlign.center, style: titleStyle),
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFCB4C), Color(0xFFDE8029)],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Text(
              'или',
              textAlign: TextAlign.center,
              style: titleStyle.copyWith(color: AppColors.white100),
            ),
          ),
          Text(secondTitle, textAlign: TextAlign.center, style: titleStyle),
        ],
      ),
    );
  }
}

class _ChoiceRewardCard extends StatelessWidget {
  const _ChoiceRewardCard({required this.reward});

  final BattlePassReward reward;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132.w,
      height: 108.h,
      child: CustomPaint(
        painter: _ParallelogramPainter(
          fillColors: reward.rarity.gradientColors,
          borderColor: reward.rarity.accentColor,
          borderWidth: 2.r,
          skew: 16.w,
          radius: 18.r,
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Image.asset(
            reward.assetPath ?? AppAssets.rewardTwo,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _RewardDetailsSheet extends StatelessWidget {
  const _RewardDetailsSheet({
    required this.reward,
    required this.choiceRewards,
    required this.level,
    required this.premiumStatus,
  });

  final BattlePassReward reward;
  final List<BattlePassReward> choiceRewards;
  final int level;
  final PremiumStatus premiumStatus;

  @override
  Widget build(BuildContext context) {
    final premiumLocked =
        reward.track == BattlePassTrack.premium &&
        premiumStatus == PremiumStatus.locked;
    final canClaim = reward.status == RewardStatus.available && !premiumLocked;
    final actionText = premiumLocked
        ? 'Прокачать'
        : reward.status == RewardStatus.received
        ? 'Получено'
        : reward.status == RewardStatus.available
        ? 'Забрать'
        : 'Заблокировано';

    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 28.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 240.w,
            height: 190.h,
            child: CustomPaint(
              painter: _ParallelogramPainter(
                fillColors: reward.rarity.gradientColors,
                borderColor: reward.rarity.accentColor,
                borderWidth: 2.r,
                skew: 24.w,
                radius: 24.r,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Image.asset(
                        reward.assetPath ?? AppAssets.rewardTwo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (reward.amount > 1)
                    Positioned(
                      right: 20.w,
                      bottom: 14.h,
                      child: _RewardAmountBadge(amount: reward.amount),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 28.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SheetPill(text: 'Уровень $level'),
                    SizedBox(width: 10.w),
                    _SheetPill(
                      text: reward.track.label,
                      color: reward.track == BattlePassTrack.premium
                          ? AppColors.gold
                          : AppColors.green,
                      textColor: AppColors.ink,
                    ),
                    if (level % 10 == 0) ...[
                      SizedBox(width: 10.w),
                      const _SheetPill(
                        text: 'Большой приз',
                        color: AppColors.orange,
                        textColor: AppColors.ink,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 14.h),
                if (choiceRewards.length > 1)
                  _ChoiceRewardTitle(rewards: choiceRewards)
                else
                  Text(
                    reward.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white100,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                if (choiceRewards.length > 1) ...[
                  SizedBox(height: 18.h),
                  Wrap(
                    spacing: 14.w,
                    runSpacing: 14.h,
                    children: [
                      for (final choiceReward in choiceRewards)
                        _ChoiceRewardCard(reward: choiceReward),
                    ],
                  ),
                ],
                SizedBox(height: 12.h),
                Text(
                  _statusText(premiumLocked),
                  style: TextStyle(
                    color: premiumLocked ? AppColors.gold : AppColors.white70,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: 230.w,
                  height: 58.h,
                  child: ElevatedButton(
                    onPressed: canClaim
                        ? () {
                            context.read<BattlePassCubit>().claimReward(
                              reward.id,
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: premiumLocked
                          ? AppColors.gold
                          : AppColors.green,
                      disabledBackgroundColor: AppColors.background10,
                      foregroundColor: AppColors.ink,
                      disabledForegroundColor: AppColors.white40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(bool premiumLocked) {
    if (premiumLocked) return 'Награда доступна только с премиум-прокачкой.';
    return switch (reward.status) {
      RewardStatus.received => 'Эта награда уже получена.',
      RewardStatus.available => 'Награда доступна. Можно забрать сейчас.',
      RewardStatus.locked => 'Откроется после достижения нужного уровня.',
    };
  }
}

class _SheetPill extends StatelessWidget {
  const _SheetPill({
    required this.text,
    this.color = AppColors.white10,
    this.textColor = AppColors.white100,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RewardAmountBadge extends StatelessWidget {
  const _RewardAmountBadge({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 69.w,
      height: 36.h,
      child: CustomPaint(
        painter: _ParallelogramPainter(
          fillColors: const [AppColors.dark, AppColors.dark, AppColors.dark],
          borderColor: AppColors.transperent,
          borderWidth: 0,
          skew: 8.w,
          radius: 10.r,
        ),
        child: Center(
          child: Text(
            'x$amount',
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 26.sp,
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.26,
            ),
          ),
        ),
      ),
    );
  }
}

class RewardTrackIcon extends StatelessWidget {
  const RewardTrackIcon({super.key, required this.track});

  final BattlePassTrack track;

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (track) {
      BattlePassTrack.free => AppAssets.freeReward,
      BattlePassTrack.premium => AppAssets.premiumReward,
    };
    return Image.asset(assetPath, width: 55.r, height: 50.r);
  }
}

class _LevelProgressMarker extends StatelessWidget {
  const _LevelProgressMarker({
    required this.level,
    required this.unlocked,
    required this.current,
    required this.drawLeftLine,
    required this.drawRightLine,
    required this.nextUnlocked,
    required this.levelProgress,
  });

  final int level;
  final bool unlocked;
  final bool current;
  final bool drawLeftLine;
  final bool drawRightLine;
  final bool nextUnlocked;
  final double levelProgress;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFEF4029);
    const inactiveColor = AppColors.background10;
    final markerColor = unlocked ? activeColor : inactiveColor;
    return SizedBox(
      width: 242.w,
      height: 60.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (drawLeftLine)
            Positioned(
              right: 121.w,
              width: 121.w,
              child: Container(height: 10.h, color: markerColor),
            ),
          if (drawRightLine)
            Positioned(
              left: 121.w,
              width: 121.w,
              child: Container(height: 10.h, color: markerColor),
            ),
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 45.r,
              height: 45.r,
              decoration: BoxDecoration(
                color: markerColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Text(
            '$level',
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              height: 1.20,
              letterSpacing: -0.22,
            ),
          ),
        ],
      ),
    );
  }
}

extension _RewardRarityGradient on RewardRarity {
  List<Color> get gradientColors {
    return switch (this) {
      RewardRarity.common => const [
        Color(0xFF29292C),
        Color(0xFF2E2E31),
        Color(0xFF5A5C60),
      ],
      RewardRarity.rare => const [
        Color(0xFF222431),
        Color(0xFF1F3351),
        Color(0xFF34779B),
      ],
      RewardRarity.epic => const [
        Color(0xFF2C232A),
        Color(0xFF4A2442),
        Color(0xFF8A1B8D),
      ],
      RewardRarity.legendary => const [
        Color(0xFF2C2323),
        Color(0xFF432723),
        Color(0xFFF05A00),
      ],
    };
  }

  Color get accentColor {
    return switch (this) {
      RewardRarity.common => const Color(0xFF737478),
      RewardRarity.rare => const Color(0xFF4CA6D3),
      RewardRarity.epic => const Color(0xFFB638B9),
      RewardRarity.legendary => const Color(0xFFFF8D2B),
    };
  }
}

extension _BattlePassTrackLabel on BattlePassTrack {
  String get label {
    return switch (this) {
      BattlePassTrack.free => 'Бесплатная',
      BattlePassTrack.premium => 'Премиум',
    };
  }
}

class _ParallelogramPainter extends CustomPainter {
  const _ParallelogramPainter({
    required this.fillColors,
    required this.borderColor,
    required this.borderWidth,
    required this.skew,
    required this.radius,
    this.glowColor,
  });

  final List<Color> fillColors;
  final Color borderColor;
  final double borderWidth;
  final double skew;
  final double radius;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _roundedParallelogramPath(size);
    final glow = glowColor;

    if (glow != null) {
      final shadowPaint = Paint()
        ..color = glow.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.r);
      canvas.drawPath(path.shift(Offset(0, 10.h)), shadowPaint);
      canvas.drawPath(path, shadowPaint);
    }

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: fillColors,
        stops: const [0, 0.48, 1],
      ).createShader(Offset.zero & size);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_ParallelogramPainter oldDelegate) {
    return oldDelegate.fillColors != fillColors ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.skew != skew ||
        oldDelegate.radius != radius ||
        oldDelegate.glowColor != glowColor;
  }

  Path _roundedParallelogramPath(Size size) {
    final points = [
      Offset(skew, 0),
      Offset(size.width, 0),
      Offset(size.width - skew, size.height),
      Offset(0, size.height),
    ];
    final path = Path();

    for (var index = 0; index < points.length; index++) {
      final previous = points[(index - 1 + points.length) % points.length];
      final current = points[index];
      final next = points[(index + 1) % points.length];
      final start = _pointAlong(current, previous, radius);
      final end = _pointAlong(current, next, radius);

      if (index == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }

      path.arcToPoint(end, radius: Radius.circular(radius));
    }

    return path..close();
  }

  Offset _pointAlong(Offset from, Offset to, double distance) {
    final vector = to - from;
    final length = vector.distance;
    if (length == 0) return from;
    return from + vector / length * distance.clamp(0, length / 2);
  }
}

class RewardStatusChip extends StatelessWidget {
  const RewardStatusChip({super.key, required this.reward});

  final BattlePassReward reward;

  @override
  Widget build(BuildContext context) {
    final text = switch (reward.status) {
      RewardStatus.locked =>
        reward.track == BattlePassTrack.premium ? 'Премиум' : 'Закрыто',
      RewardStatus.available => 'Можно',
      RewardStatus.received => '✓',
    };
    return Container(
      constraints: BoxConstraints(maxWidth: 70.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: reward.status == RewardStatus.received
            ? AppColors.green
            : AppColors.gold,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
