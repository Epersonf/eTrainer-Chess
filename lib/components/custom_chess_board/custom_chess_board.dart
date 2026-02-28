import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:e_trainer_chess/features/analysis/models/engine_arrow.dart';
import 'package:e_trainer_chess/features/analysis/models/square_stats.dart';

import 'board_square.dart';
import 'arrow_painter.dart';

class CustomChessBoard extends StatelessWidget {
  final String fen;
  final bool isWhiteBottom;
  final bool showCoordinates;
  final Map<String, SquareStats>? heatmapData;
  final Set<String>? weakSquares;
  final List<EngineArrow>? arrows;
  final Function(String from, String to, [String? promotion])? onMove;

  const CustomChessBoard({
    super.key,
    required this.fen,
    this.isWhiteBottom = true,
    this.showCoordinates = false,
    this.heatmapData,
    this.weakSquares,
    this.arrows,
    this.onMove,
  });

  static const pieceNameMap = {
    'p': 'pawn', 'n': 'knight', 'b': 'bishop',
    'r': 'rook', 'q': 'queen', 'k': 'king',
  };

  @override
  Widget build(BuildContext context) {
    final game = chess_lib.Chess()..load(fen);

    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = constraints.maxWidth;
          final squareSize = boardSize / 8;

          return SizedBox(
            width: boardSize,
            height: boardSize,
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    return BoardSquare(
                      key: ValueKey('square_${index}_$isWhiteBottom'),
                      index: index,
                      game: game,
                      squareSize: squareSize,
                      isWhiteBottom: isWhiteBottom,
                      showCoordinates: showCoordinates,
                      heatmapData: heatmapData,
                      weakSquares: weakSquares,
                      onMove: onMove,
                    );
                  },
                ),
                if (arrows != null && arrows!.isNotEmpty)
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(boardSize, boardSize),
                      painter: GenericArrowPainter(arrows!, squareSize, isWhiteBottom),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
