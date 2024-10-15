import 'package:flutter/material.dart';

class RoundedSquareClipper extends CustomClipper<Path> {
  final double squareSize;
  final double borderRadius;

  RoundedSquareClipper({
    required this.squareSize,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    // Fill the entire path with transparency
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // Cut out the clear rounded square area in the center
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - squareSize) / 2,
          (size.height - squareSize) / 2 - 100, // Shifted upwards by 50 units
          squareSize,
          squareSize,
        ),
        Radius.circular(borderRadius),
      ),
    );
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
