import 'package:flutter/material.dart';

class AppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Background Gradient (Dark Blue/Purple Theme)
    final RRect backgroundRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(width * 0.22), // App Icon rounding
    );

    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF131B2E),
          Color(0xFF090D16),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRRect(backgroundRRect, backgroundPaint);

    // Glowing Neon Ring
    final Paint glowPaint = Paint()
      ..color = const Color(0xFF5B61F6).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(Offset(width / 2, height / 2), width * 0.3, glowPaint);

    // Center AI Icon Symbol
    final Paint circlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8B2FC9),
          Color(0xFF5B61F6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawCircle(Offset(width / 2, height / 2), width * 0.22, circlePaint);

    // Inner Circuit / Brain Nodes
    final Paint nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = width * 0.02
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(width / 2, height / 2);

    // Draw central spark nodes
    canvas.drawLine(center, Offset(width * 0.38, height * 0.38), linePaint);
    canvas.drawLine(center, Offset(width * 0.62, height * 0.38), linePaint);
    canvas.drawLine(center, Offset(width * 0.5, height * 0.65), linePaint);

    canvas.drawCircle(Offset(width * 0.38, height * 0.38), width * 0.035, nodePaint);
    canvas.drawCircle(Offset(width * 0.62, height * 0.38), width * 0.035, nodePaint);
    canvas.drawCircle(Offset(width * 0.5, height * 0.65), width * 0.035, nodePaint);
    canvas.drawCircle(center, width * 0.05, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}