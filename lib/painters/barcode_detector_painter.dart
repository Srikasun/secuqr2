import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:secuqr/colors/appcolor.dart';

import 'coordinates_translator.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(
    this.barcodes,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.onBarcodeSizeChanged,
    Size size, // Add a callback for barcode size changes
  );

  final List<Barcode> barcodes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final void Function(double) onBarcodeSizeChanged; // Callback type

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill // Use fill style
      ..color = AppColors.purpleNeonColor
          .withOpacity(0.8); // Semi-transparent color for filling

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = AppColors.purpleNeonColor;

    final Paint background = Paint()..color = const Color(0x99000000);

    double maxBoundingBoxSize = 0;

    for (final Barcode barcode in barcodes) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 16,
          textDirection: TextDirection.ltr,
        ),
      );
      builder.pushStyle(ui.TextStyle(
          color: AppColors.purpleNeonColor, background: background));
      builder.addText('${barcode.displayValue}');
      builder.pop();

      final left = translateX(
        barcode.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        barcode.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        barcode.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        barcode.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      final width = right - left;
      final height = bottom - top;
      final boundingBoxSize = width * height;

      if (boundingBoxSize > maxBoundingBoxSize) {
        maxBoundingBoxSize = boundingBoxSize;
      }

      final Path path = Path();
      final List<Offset> cornerPoints = <Offset>[];
      for (final point in barcode.cornerPoints) {
        final double x = translateX(
          point.x.toDouble(),
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );
        final double y = translateY(
          point.y.toDouble(),
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        );

        cornerPoints.add(Offset(x, y));
      }

      // Close the path
      path.addPolygon(cornerPoints, true);

      // Fill the path
      canvas.drawPath(path, fillPaint);

      // Draw the border (optional)
      canvas.drawPath(path, borderPaint);

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: (right - left).abs(),
          )),
        Offset(
          Platform.isAndroid && cameraLensDirection == CameraLensDirection.front
              ? right
              : left,
          top,
        ),
      );
    }

    // Notify the parent or controller about the maximum barcode size
    if (maxBoundingBoxSize > 0) {
      onBarcodeSizeChanged(maxBoundingBoxSize);
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.barcodes != barcodes;
  }
}
