import 'package:flutter/material.dart';

class CornerBorderPainter extends CustomPainter {
  final double squareSize;
  final double borderWidth;
  final Color borderColor;
  final double cornerRadius; // Corner radius for curved corners
  final double
      offset; // Additional offset for spacing between border and square

  CornerBorderPainter({
    required this.squareSize,
    required this.borderWidth,
    required this.borderColor,
    required this.cornerRadius, // Initialize corner radius
    this.offset = 10.0, // Default offset to move the border away
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Adjust position by adding offset
    final double left = (size.width - squareSize) / 2 - offset;
    final double top = (size.height - squareSize) / 2 - 100 - offset;
    final double adjustedSquareSize = squareSize + (2 * offset);

    Path path = Path();
    // Top-left corner with curved lines
    path.moveTo(left + adjustedSquareSize / 6, top); // Start before the corner
    path.lineTo(left + cornerRadius, top); // Partial line towards the corner
    path.arcToPoint(
      Offset(left, top + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false, // Correct arc direction
    ); // Curved arc for the corner
    path.lineTo(left, top + adjustedSquareSize / 6); // Partial line downwards

    // Top-right corner with curved lines
    path.moveTo(
      left + adjustedSquareSize - adjustedSquareSize / 6,
      top,
    ); // Start before the corner
    path.lineTo(
      left + adjustedSquareSize - cornerRadius,
      top,
    ); // Partial line towards the corner
    path.arcToPoint(
      Offset(left + adjustedSquareSize, top + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true, // Change to true for a clockwise arc
    ); // Curved arc for the corner
    path.lineTo(
      left + adjustedSquareSize,
      top + adjustedSquareSize / 6,
    ); // Partial line downwards

    // Bottom-left corner with curved lines
    path.moveTo(
        left,
        top +
            adjustedSquareSize -
            adjustedSquareSize / 6); // Start before the bottom edge
    path.lineTo(
        left, top + adjustedSquareSize - cornerRadius); // Partial line upwards
    path.arcToPoint(
      Offset(left + cornerRadius, top + adjustedSquareSize),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    ); // Curved arc for the corner
    path.lineTo(left + adjustedSquareSize / 6,
        top + adjustedSquareSize); // Partial line towards the center

    // Bottom-right corner with curved lines
    path.moveTo(
      left + adjustedSquareSize,
      top + adjustedSquareSize - adjustedSquareSize / 6,
    ); // Start before the bottom edge
    path.lineTo(
      left + adjustedSquareSize,
      top + adjustedSquareSize - cornerRadius,
    ); // Partial line upwards
    path.arcToPoint(
      Offset(
          left + adjustedSquareSize - cornerRadius, top + adjustedSquareSize),
      radius: Radius.circular(cornerRadius),
      clockwise: true, // Change to true for a clockwise arc
    ); // Curved arc for the corner
    path.lineTo(
      left + adjustedSquareSize - adjustedSquareSize / 6,
      top + adjustedSquareSize,
    ); // Partial line towards the center

    // Draw the path for the curved corners
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
