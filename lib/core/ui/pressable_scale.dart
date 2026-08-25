import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onLongPressCancel,
    this.enabled = true,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 110),
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressEndCallback? onLongPressEnd;
  final VoidCallback? onLongPressCancel;
  final bool enabled;
  final double pressedScale;
  final Duration duration;
  final HitTestBehavior behavior;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;

    return GestureDetector(
      onTap: enabled ? widget.onTap : null,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onLongPressStart: enabled
          ? (details) {
              _setPressed(true);
              widget.onLongPressStart?.call(details);
            }
          : null,
      onLongPressEnd: enabled
          ? (details) {
              _setPressed(false);
              widget.onLongPressEnd?.call(details);
            }
          : null,
      onLongPressCancel: enabled
          ? () {
              _setPressed(false);
              widget.onLongPressCancel?.call();
            }
          : null,
      behavior: widget.behavior,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(opacity: enabled ? 1 : 0.58, duration: widget.duration, curve: Curves.easeOutCubic, child: widget.child),
      ),
    );
  }
}
