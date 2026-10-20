import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';

class SoftGradientCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry margin;
 
  const SoftGradientCard({
    super.key,
    required this.child,
    this.radius = 16,
    this.margin = const EdgeInsets.all(4),
  });
 
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
 
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryScheme.withAlpha(45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardGradientStart,
                  AppColors.cardGradientEnd,
                ],
              ),
            ),
            child: CustomPaint(
              painter: _SoftEdgePainter(borderRadius: borderRadius),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
 
class _SoftEdgePainter extends CustomPainter {
  final BorderRadius borderRadius;
 
  const _SoftEdgePainter({required this.borderRadius});
 
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
 
    canvas.save();
    canvas.clipRRect(rrect);
 
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.1,
          colors: [Colors.white.withAlpha(22), Colors.white.withAlpha(0)],
        ).createShader(rect),
    );
 
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = Colors.white.withAlpha(38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
 
    canvas.restore();
  }
 
  @override
  bool shouldRepaint(covariant _SoftEdgePainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius;
}