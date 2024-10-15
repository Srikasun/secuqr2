import 'package:flutter/material.dart';

class GradientShadowPainter extends CustomPainter {
  final Gradient gradient;
  final double blurRadius;

  GradientShadowPainter({required this.gradient, this.blurRadius = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
