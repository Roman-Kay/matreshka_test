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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pass = widget.state.battlePass!;
    final levels = pass.season.levels;

    return Container(
      decoration: BoxDecoration(color: const Color(0x553A0A0A), borderRadius: BorderRadius.circular(8.r)),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 26.h),
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final reward = _rewardForLevel(level, widget.state.selectedRewardId);
          final isLastLevel = index == levels.length - 1;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              RewardCard(level: level.number, reward: reward, selected: widget.state.selectedRewardId == reward.id, progress: pass.progress, isFirstLevel: index == 0, isLastLevel: isLastLevel),
              if (!isLastLevel)
                Positioned(
                  right: -5.w,
                  top: 184.h / 2,
                  child: SvgPicture.asset(AppAssets.arrowRoad, width: 12.w, height: 20.h),
                ),
            ],
          );
        },
      ),
    );
  }

  BattlePassReward _rewardForLevel(BattlePassLevel level, int? selectedId) {
    final rewards = [...level.freeRewards, ...level.premiumRewards];
    for (final reward in rewards) {
      if (reward.id == selectedId) return reward;
    }

    if (level.premiumRewards.isNotEmpty) return level.premiumRewards.first;
    return level.freeRewards.first;
  }
}

class RewardCard extends StatelessWidget {
  const RewardCard({super.key, required this.level, required this.reward, required this.selected, required this.progress, required this.isFirstLevel, required this.isLastLevel});

  final int level;
  final BattlePassReward reward;
  final bool selected;
  final BattlePassProgress progress;
  final bool isFirstLevel;
  final bool isLastLevel;

  @override
  Widget build(BuildContext context) {
    final available = reward.status == RewardStatus.available;
    final unlocked = level <= progress.currentLevel;
    return InkWell(
      onTap: () => context.read<BattlePassCubit>().selectReward(reward.id),
      onLongPress: () => _showDetails(context),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 242.w,
        height: 300.h,
        child: Column(
          children: [
            Container(
              width: 210.w,
              height: 184.h,
              child: Center(
                child: CustomPaint(
                  painter: _ParallelogramPainter(
                    fillColors: available ? const [Color(0xCC56B877), Color(0x8856B877)] : const [Color(0x88530202), Color(0xAA7C1404)],
                    borderColor: selected ? AppColors.green : AppColors.white40,
                    borderWidth: selected ? 4.r : 1.r,
                    skew: 26.w,
                    radius: 24.r,
                  ),
                  child: Stack(
                    children: [
                      Positioned(left: 0, top: 0, child: RewardStatusChip(reward: reward)),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 18.h, bottom: 10.h),
                          child: Image.asset(reward.assetPath ?? AppAssets.rewardTwo, fit: BoxFit.contain),
                        ),
                      ),
                      if (reward.amount > 1)
                        Positioned(
                          right: 28.w,
                          bottom: 12.h,
                          child: _RewardAmountBadge(amount: reward.amount),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            // _ClaimButton(available: available, reward: reward),
            //  const Spacer(),
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
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Text('${reward.title}\nТип: ${reward.type.name}\nСтатус: ${reward.status.name}', style: TextStyle(fontSize: 22.sp)),
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
        painter: _ParallelogramPainter(fillColors: const [AppColors.dark, AppColors.dark], borderColor: AppColors.transperent, borderWidth: 0, skew: 8.w, radius: 10.r),
        child: Center(
          child: Text(
            'x$amount',
            style: TextStyle(color: AppColors.white100, fontSize: 26.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.26),
          ),
        ),
      ),
    );
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
              decoration: BoxDecoration(color: markerColor, borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
          Text(
            '$level',
            style: TextStyle(color: AppColors.white100, fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.20, letterSpacing: -0.22),
          ),
        ],
      ),
    );
  }
}

class _ParallelogramPainter extends CustomPainter {
  const _ParallelogramPainter({required this.fillColors, required this.borderColor, required this.borderWidth, required this.skew, required this.radius});

  final List<Color> fillColors;
  final Color borderColor;
  final double borderWidth;
  final double skew;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _roundedParallelogramPath(size);

    final fill = Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fillColors).createShader(Offset.zero & size);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_ParallelogramPainter oldDelegate) {
    return oldDelegate.fillColors != fillColors || oldDelegate.borderColor != borderColor || oldDelegate.borderWidth != borderWidth || oldDelegate.skew != skew || oldDelegate.radius != radius;
  }

  Path _roundedParallelogramPath(Size size) {
    final points = [Offset(skew, 0), Offset(size.width, 0), Offset(size.width - skew, size.height), Offset(0, size.height)];
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
      RewardStatus.locked => reward.track == BattlePassTrack.premium ? 'Премиум' : 'Закрыто',
      RewardStatus.available => 'Можно',
      RewardStatus.received => '✓',
    };
    return Container(
      constraints: BoxConstraints(maxWidth: 70.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(color: reward.status == RewardStatus.received ? AppColors.green : AppColors.gold, borderRadius: BorderRadius.circular(6.r)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.ink, fontSize: 11.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}
