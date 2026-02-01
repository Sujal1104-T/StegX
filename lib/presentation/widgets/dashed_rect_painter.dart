
import 'package:flutter/material.dart';

// Simple Utility for Dashed Border
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({this.color = Colors.white, this.strokeWidth = 1, this.gap = 5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // For simplicity, we just draw the path. One could implement true dashing here.
    // Given the constraints and the previous implementation, we keep it simple or upgrade it.
    // The previous implementation was:
    // canvas.drawPath(dashPath, paint);
    // where dashPath calls _dashPath which returned source. 
    // Let's implement a simple dash loop for better UX.
    
    _drawDashedRect(canvas, paint, size);
  }

  void _drawDashedRect(Canvas canvas, Paint paint, Size size) {
    double dashWidth = 10; 
    double dashSpace = gap;
    
    // Top
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    
    // Right
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    // Bottom
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX - dashWidth, size.height), paint);
      startX -= dashWidth + dashSpace;
    }

    // Left
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }
  
  // Note: CircularIntervalList was unused in previous valid logic or just helper.
  // We can remove it if we use explicit loops.
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
