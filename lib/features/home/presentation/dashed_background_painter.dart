import 'package:flutter/material.dart';

class DashedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark blue-grey base color
    final baseColor = const Color(0xFF2A3A4A);
    final rectColor = const Color(0xFF1E2A3A);
    final dashColor = const Color(0xFF4A5A6A);
    final bottomBandColor = const Color(0xFF1A1A1A);
    
    // Fill base background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );
    
    // Draw scattered rectangular shapes
    final rectPaint = Paint()..color = rectColor;
    const rectWidth = 12.0;
    const rectHeight = 8.0;
    const rectSpacing = 20.0;
    
    for (double x = 0; x < size.width; x += rectSpacing) {
      for (double y = 0; y < size.height - 20; y += rectSpacing) {
        // Offset every other row
        final offsetX = (y / rectSpacing).floor() % 2 == 0 ? 0 : rectSpacing / 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + offsetX, y, rectWidth, rectHeight),
            const Radius.circular(2),
          ),
          rectPaint,
        );
      }
    }
    
    // Draw three vertical dashed lines
    final dashPaint = Paint()
      ..color = dashColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    const dashHeight = 8.0;
    const dashSpace = 6.0;
    final lineSpacing = size.width / 4; // Three lines with spacing
    
    for (int lineIndex = 0; lineIndex < 3; lineIndex++) {
      final x = lineSpacing * (lineIndex + 1);
      double y = 0;
      
      while (y < size.height - 20) { // Leave space for bottom band
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + dashHeight),
          dashPaint,
        );
        y += dashHeight + dashSpace;
      }
    }
    
    // Draw bottom horizontal band
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 20, size.width, 20),
      Paint()..color = bottomBandColor,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
