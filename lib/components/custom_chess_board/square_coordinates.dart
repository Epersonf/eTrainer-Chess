import 'package:flutter/material.dart';

class SquareCoordinates extends StatelessWidget {
  final int fileIndex;
  final int rankIndex;
  final int file;
  final int rank;

  const SquareCoordinates({
    super.key,
    required this.fileIndex,
    required this.rankIndex,
    required this.file,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    const coordStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
    );

    final isBottomEdge = rankIndex == 7;
    final isLeftEdge = fileIndex == 0;

    return Stack(
      children: [
        if (isLeftEdge)
          Positioned(
            top: 2,
            left: 2,
            child: Text('$rank', style: coordStyle),
          ),
        if (isBottomEdge)
          Positioned(
            bottom: 2,
            right: 2,
            child: Text(String.fromCharCode(97 + file), style: coordStyle),
          ),
      ],
    );
  }
}
