import 'package:flutter/material.dart';
import '../models/engine_arrow.dart';

class ArrowPainter extends CustomPainter {
  final List<EngineArrow> arrows;
  final double squareSize;

  ArrowPainter(this.arrows, this.squareSize);

  Offset _getCenter(String square) {
    final file = square.codeUnitAt(0) - 97;
    final rank = int.parse(square[1]);
    final x = (file * squareSize) + (squareSize / 2);
    final y = ((8 - rank) * squareSize) + (squareSize / 2);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final arrow in arrows) {
      final p1 = _getCenter(arrow.from);
      final p2 = _getCenter(arrow.to);

      canvas.drawLine(p1, p2, paint);

      canvas.drawCircle(p2, 8.0, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) => true;
}
