import 'package:flutter/widgets.dart';

class CountdownText extends StatelessWidget {
  const CountdownText({
    super.key,
    required this.endsAt,
    required this.style,
    this.textAlign,
  });

  final DateTime endsAt;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream<DateTime>.periodic(
        const Duration(minutes: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        return Text(
          _formatRemaining(snapshot.data ?? DateTime.now()),
          textAlign: textAlign,
          style: style,
        );
      },
    );
  }

  String _formatRemaining(DateTime now) {
    final remaining = endsAt.difference(now);
    if (remaining <= Duration.zero) return '0д 0ч 0м';

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    return '$daysд $hoursч $minutesм';
  }
}
