import 'package:flutter/material.dart';
import 'package:e_trainer_chess/features/analysis/models/engine_arrow.dart';

class GenericArrowPainter extends CustomPainter {
  final List<EngineArrow> arrows;
  final double squareSize;
  final bool isWhiteBottom;

  GenericArrowPainter(this.arrows, this.squareSize, this.isWhiteBottom);

  Offset _getCenter(String square) {
    final fileStr = square.codeUnitAt(0) - 97;
    final rankStr = int.parse(square[1]);

    final displayFile = isWhiteBottom ? fileStr : 7 - fileStr;
    final displayRank = isWhiteBottom ? 8 - rankStr : rankStr - 1;

    final x = (displayFile * squareSize) + (squareSize / 2);
    final y = (displayRank * squareSize) + (squareSize / 2);
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
  bool shouldRepaint(covariant GenericArrowPainter oldDelegate) => true;
}
