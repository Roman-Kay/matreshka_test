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

  @override
  Widget build(BuildContext context) {
    final pass = widget.state.battlePass!;
    final levels = pass.season.levels;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x553A0A0A),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pinLeft = constraints.maxWidth - 56.w - 242.w;
          final pinnedPrizeLevel = _pinnedPrizeLevel(levels, pinLeft);
          final pinnedPrizeReward = pinnedPrizeLevel == null
              ? null
              : _bigPrizeReward(pinnedPrizeLevel);

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 0),
                scrollDirection: Axis.horizontal,
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  final reward = _rewardForLevel(
                    level,
                    widget.state.selectedRewardId,
                  );
                  final isLastLevel = index == levels.length - 1;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      RewardCard(
                        level: level.number,
                        reward: reward,
                        selected: widget.state.selectedRewardId == reward.id,
                        progress: pass.progress,
                        premiumStatus: pass.premiumStatus,
                        isFirstLevel: index == 0,
                        isLastLevel: isLastLevel,
                      ),
                      if (!isLastLevel)
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
              Positioned(
                right: 56.w,
                top: 0,
                child: IgnorePointer(
                  ignoring: pinnedPrizeLevel == null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    reverseDuration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final direction = _scrollDirection.toDouble();
                      final slide = Tween<Offset>(
                        begin: Offset(direction * 0.45, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: pinnedPrizeLevel == null || pinnedPrizeReward == null
                        ? SizedBox(
                            key: const ValueKey('empty-big-prize'),
                            width: 242.w,
                            height: 280.h,
                          )
                        : _PinnedBigPrizeCard(
                            key: ValueKey(
                              'big-prize-${pinnedPrizeLevel.number}',
                            ),
                            level: pinnedPrizeLevel.number,
                            reward: pinnedPrizeReward,
                            selected:
                                widget.state.selectedRewardId ==
                                pinnedPrizeReward.id,
                            onTap: () => context
                                .read<BattlePassCubit>()
                                .selectReward(pinnedPrizeReward.id),
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

  double _bigPrizeLeftInViewport(int level) {
    return 40.w + (level - 1) * 242.w - _scrollOffset;
  }

  BattlePassLevel? _pinnedPrizeLevel(
    List<BattlePassLevel> levels,
    double pinLeft,
  ) {
    final levelAtPin = (_scrollOffset + pinLeft - 40.w) / 242.w + 1;
    final passedPrizeLevel = (levelAtPin ~/ 10) * 10;
    final nextPrizeLevel = passedPrizeLevel + 10;
    final canShowNextPrize =
        passedPrizeLevel == 0 || levelAtPin >= passedPrizeLevel + 2;

    if (!canShowNextPrize) return null;

    for (final level in levels) {
      if (level.number == nextPrizeLevel &&
          _bigPrizeLeftInViewport(level.number) > pinLeft) {
        return level;
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
    required this.selected,
    required this.progress,
    required this.premiumStatus,
    required this.isFirstLevel,
    required this.isLastLevel,
  });

  final int level;
  final BattlePassReward reward;
  final bool selected;
  final BattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final bool isFirstLevel;
  final bool isLastLevel;

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
              drawLeftLine: !isFirstLevel,
              drawRightLine: !isLastLevel,
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

class _PinnedBigPrizeCard extends StatelessWidget {
  const _PinnedBigPrizeCard({
    super.key,
    required this.level,
    required this.reward,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final BattlePassReward reward;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 242.w,
        height: 280.h,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 242.w,
              height: 220.h,
              child: CustomPaint(
                painter: _ParallelogramPainter(
                  fillColors: reward.rarity.gradientColors,
                  borderColor: selected ? AppColors.white100 : AppColors.orange,
                  borderWidth: 4.r,
                  skew: 26.w,
                  radius: 24.r,
                  glowColor: AppColors.orange,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(28.w, 22.h, 20.w, 18.h),
                        child: Image.asset(
                          reward.assetPath ?? AppAssets.hero,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22.w,
                      top: 10.h,
                      child: RewardTrackIcon(track: reward.track),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 14.h,
              child: _BigPrizeLevelBadge(level: level),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigPrizeLevelBadge extends StatelessWidget {
  const _BigPrizeLevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: 48.r,
        height: 48.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background10,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Transform.rotate(
          angle: -pi / 4,
          child: Text(
            '$level',
            style: TextStyle(
              color: AppColors.white100,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardDetailsSheet extends StatelessWidget {
  const _RewardDetailsSheet({
    required this.reward,
    required this.level,
    required this.premiumStatus,
  });

  final BattlePassReward reward;
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
