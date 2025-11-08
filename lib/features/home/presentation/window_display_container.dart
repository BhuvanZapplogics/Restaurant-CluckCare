import 'package:flutter/material.dart';

class WindowDisplayContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const WindowDisplayContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: WindowDisplayPainter(),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class WindowDisplayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark navy central area
    final centralColor = const Color(0xFF1A1A2E);
    // Medium blue-grey inner border
    final innerBorderColor = const Color(0xFF4A5A6A);
    // Fuzzy/embroidered outer edge
    final outerEdgeColor = const Color(0xFF0F0F0F);
    
    final path = Path();
    
    // Create the arched-top shape
    final topRadius = size.width * 0.15; // 15% of width for the arch
    final borderWidth = 3.0;
    final outerBorderWidth = 2.0;
    
    // Main shape path (arched top, straight bottom)
    path.moveTo(borderWidth, topRadius + borderWidth);
    path.quadraticBezierTo(
      borderWidth, borderWidth,
      borderWidth + topRadius, borderWidth,
    );
    path.lineTo(size.width - borderWidth - topRadius, borderWidth);
    path.quadraticBezierTo(
      size.width - borderWidth, borderWidth,
      size.width - borderWidth, topRadius + borderWidth,
    );
    path.lineTo(size.width - borderWidth, size.height - borderWidth);
    path.lineTo(borderWidth, size.height - borderWidth);
    path.close();
    
    // Fill central dark area
    canvas.drawPath(
      path,
      Paint()..color = centralColor,
    );
    
    // Draw inner border
    final innerPath = Path();
    innerPath.moveTo(borderWidth, topRadius + borderWidth);
    innerPath.quadraticBezierTo(
      borderWidth, borderWidth,
      borderWidth + topRadius, borderWidth,
    );
    innerPath.lineTo(size.width - borderWidth - topRadius, borderWidth);
    innerPath.quadraticBezierTo(
      size.width - borderWidth, borderWidth,
      size.width - borderWidth, topRadius + borderWidth,
    );
    innerPath.lineTo(size.width - borderWidth, size.height - borderWidth);
    innerPath.lineTo(borderWidth, size.height - borderWidth);
    innerPath.close();
    
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = innerBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
    
    // Draw fuzzy outer edge effect
    final outerPath = Path();
    final outerOffset = borderWidth + outerBorderWidth;
    outerPath.moveTo(outerOffset, topRadius + outerOffset);
    outerPath.quadraticBezierTo(
      outerOffset, outerOffset,
      outerOffset + topRadius, outerOffset,
    );
    outerPath.lineTo(size.width - outerOffset - topRadius, outerOffset);
    outerPath.quadraticBezierTo(
      size.width - outerOffset, outerOffset,
      size.width - outerOffset, topRadius + outerOffset,
    );
    outerPath.lineTo(size.width - outerOffset, size.height - outerOffset);
    outerPath.lineTo(outerOffset, size.height - outerOffset);
    outerPath.close();
    
    // Create fuzzy effect with multiple strokes
    for (int i = 0; i < 3; i++) {
      canvas.drawPath(
        outerPath,
        Paint()
          ..color = outerEdgeColor.withOpacity(0.3 - (i * 0.1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + (i * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

