import 'package:flutter/material.dart';

class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.animateOnTap = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final bool animateOnTap;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1.0;

  Future<void> _handleTap() async {
    if (!widget.animateOnTap) {
      widget.onTap?.call();
      return;
    }

    setState(() => _scale = 0.95);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _scale = 1.0);
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}