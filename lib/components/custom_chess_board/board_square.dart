import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:e_trainer_chess/features/analysis/models/square_stats.dart';

import 'custom_chess_board.dart';
import 'promotion_dialog.dart';
import 'square_coordinates.dart';
import 'square_stats_badge.dart';

class BoardSquare extends StatelessWidget {
  final int index;
  final chess_lib.Chess game;
  final double squareSize;
  final bool isWhiteBottom;
  final bool showCoordinates;
  final Map<String, SquareStats>? heatmapData;
  final Function(String from, String to, [String? promotion])? onMove;

  const BoardSquare({
    super.key,
    required this.index,
    required this.game,
    required this.squareSize,
    required this.isWhiteBottom,
    required this.showCoordinates,
    this.heatmapData,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final int rankIndex = index ~/ 8;
    final int fileIndex = index % 8;

    final int rank = isWhiteBottom ? 8 - rankIndex : rankIndex + 1;
    final int file = isWhiteBottom ? fileIndex : 7 - fileIndex;

    final String squareName = '${String.fromCharCode(97 + file)}$rank';
    final bool isLightSquare = (rank + file) % 2 != 0;

    final piece = game.get(squareName);
    final stats = heatmapData?[squareName];
    final isUnderAttack = stats != null && stats.attacks > stats.defenses;

    Widget pieceWidget = const SizedBox.shrink();

    if (piece != null) {
      final colorStr = piece.color == chess_lib.Color.WHITE ? 'white' : 'black';
      final pieceName = CustomChessBoard.pieceNameMap[piece.type.toLowerCase()];
      final assetPath = 'assets/pieces/$colorStr/$colorStr-$pieceName.png';

      pieceWidget = Image.asset(assetPath, fit: BoxFit.contain);

      if (onMove != null && piece.color == game.turn) {
        pieceWidget = Draggable<String>(
          data: squareName,
          feedback: SizedBox(
            width: squareSize,
            height: squareSize,
            child: pieceWidget,
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: pieceWidget,
          ),
          child: pieceWidget,
        );
      }
    }

    return DragTarget<String>(
      onAcceptWithDetails: (details) async {
        final fromSquare = details.data;
        if (fromSquare != squareName && onMove != null) {
          final movingPiece = game.get(fromSquare);
          bool isPromotion = false;

          if (movingPiece != null && movingPiece.type.toLowerCase() == 'p') {
            final targetRank = squareName[1];
            if (targetRank == '1' || targetRank == '8') {
              isPromotion = true;
            }
          }

          if (isPromotion) {
            final colorStr = movingPiece!.color == chess_lib.Color.WHITE ? 'white' : 'black';
            final promoPiece = await showDialog<String>(
              context: context,
              builder: (ctx) => PromotionDialog(colorStr: colorStr),
            );

            if (promoPiece != null) {
              onMove!(fromSquare, squareName, promoPiece);
            }
          } else {
            onMove!(fromSquare, squareName);
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? Colors.cyanAccent.withOpacity(0.5)
              : (isLightSquare ? const Color(0xFFF0D9B5) : const Color(0xFFB58863)),
          child: Stack(
            children: [
              if (heatmapData != null && isUnderAttack)
                Container(color: Colors.redAccent.withOpacity(0.4)),
              
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(child: pieceWidget),
              ),

              if (showCoordinates)
                SquareCoordinates(
                  fileIndex: fileIndex,
                  rankIndex: rankIndex,
                  file: file,
                  rank: rank,
                ),

              if (stats != null)
                Positioned(
                  bottom: 2,
                  left: 2,
                  right: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SquareStatsBadge(icon: Icons.bolt, value: stats.attacks, iconColor: Colors.amber),
                      SquareStatsBadge(icon: Icons.shield, value: stats.defenses, iconColor: Colors.lightBlueAccent),
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
