import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:e_trainer_chess/features/analysis/models/engine_arrow.dart';
import 'package:e_trainer_chess/features/analysis/models/square_stats.dart';

class CustomChessBoard extends StatelessWidget {
  final String fen;
  final bool isWhiteBottom;
  final bool showCoordinates;
  final Map<String, SquareStats>? heatmapData;
  final List<EngineArrow>? arrows;
  final Function(String from, String to, [String? promotion])? onMove;

  const CustomChessBoard({
    super.key,
    required this.fen,
    this.isWhiteBottom = true,
    this.showCoordinates = false,
    this.heatmapData,
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
                      final pieceName = pieceNameMap[piece.type.toLowerCase()];
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
                              builder: (ctx) => _PromotionDialog(colorStr: colorStr),
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

                              if (showCoordinates) ..._buildCoordinates(fileIndex, rankIndex, file, rank),

                              if (stats != null)
                                Positioned(
                                  bottom: 2, left: 2, right: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildBadge(Icons.bolt, stats.attacks, Colors.amber),
                                      _buildBadge(Icons.shield, stats.defenses, Colors.lightBlueAccent),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                if (arrows != null && arrows!.isNotEmpty)
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(boardSize, boardSize),
                      painter: _GenericArrowPainter(arrows!, squareSize, isWhiteBottom),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCoordinates(int fileIndex, int rankIndex, int file, int rank) {
    const coordStyle = TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold);
    final isBottomEdge = rankIndex == 7;
    final isLeftEdge = fileIndex == 0;
    
    return [
      if (isLeftEdge)
        Positioned(top: 2, left: 2, child: Text('$rank', style: coordStyle)),
      if (isBottomEdge)
        Positioned(bottom: 2, right: 2, child: Text(String.fromCharCode(97 + file), style: coordStyle)),
    ];
  }

  Widget _buildBadge(IconData icon, int value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 10),
          const SizedBox(width: 2),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }
}

class _GenericArrowPainter extends CustomPainter {
  final List<EngineArrow> arrows;
  final double squareSize;
  final bool isWhiteBottom;

  _GenericArrowPainter(this.arrows, this.squareSize, this.isWhiteBottom);

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
  bool shouldRepaint(covariant _GenericArrowPainter oldDelegate) => true;
}

class _PromotionDialog extends StatelessWidget {
  final String colorStr;
  
  const _PromotionDialog({required this.colorStr});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text('Promover peão', style: TextStyle(color: Colors.white)),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['q', 'r', 'b', 'n'].map((pieceStr) {
          final pieceName = CustomChessBoard.pieceNameMap[pieceStr];
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(pieceStr),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/pieces/$colorStr/$colorStr-$pieceName.png',
                width: 48,
                height: 48,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
