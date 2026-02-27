import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../services/stores/analysis.store.dart';
import 'arrow_painter.dart';

class AnalysisBoard extends StatelessWidget {
  final AnalysisStore store;

  const AnalysisBoard({super.key, required this.store});

  // Mapa simples para desenhar as peças em Unicode
  static const pieceMap = {
    'p': '♟', 'n': '♞', 'b': '♝', 'r': '♜', 'q': '♛', 'k': '♚', // Pretas
    'P': '♙', 'N': '♘', 'B': '♗', 'R': '♖', 'Q': '♕', 'K': '♔', // Brancas
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
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
                  final int rank = 8 - (index ~/ 8);
                  final int file = index % 8;
                  final String squareName = '${String.fromCharCode(97 + file)}$rank';
                  final bool isLightSquare = (rank + file) % 2 != 0;

                  return Observer(builder: (_) {
                    // Lendo o FEN atual só para forçar a re-renderização do Observer
                    final _ = store.currentFen;

                    final stats = store.heatmapData[squareName];
                    final isUnderAttack = stats != null && stats.attacks > stats.defenses;

                    // Lendo a peça real da biblioteca
                    final chess_lib.Piece? piece = store.game.get(squareName);
                    Widget pieceWidget = const SizedBox.shrink();

                    if (piece != null) {
                      final char = piece.color == chess_lib.Color.WHITE
                          ? piece.type.toUpperCase()
                          : piece.type.toLowerCase();
                      pieceWidget = Center(
                        child: Text(
                          pieceMap[char]!,
                          style: const TextStyle(fontSize: 42, color: Colors.black, height: 1.1),
                        ),
                      );
                    }

                    return Container(
                      color: isLightSquare ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
                      child: Stack(
                        children: [
                          if (store.showHeatmap && isUnderAttack)
                            Container(color: Colors.redAccent.withOpacity(0.4)),

                          pieceWidget, // <-- Peça Real

                          if (store.showHeatmap && stats != null)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              left: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.shield, color: Colors.blueAccent, size: 14),
                                      Text('${stats.defenses}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('${stats.attacks}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const Icon(Icons.bolt, color: Colors.amber, size: 14),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    );
                  });
                },
              ),

              Observer(builder: (_) {
                if (!store.showEngine || store.engineArrows.isEmpty) return const SizedBox.shrink();
                return IgnorePointer(
                  child: CustomPaint(
                    size: Size(boardSize, boardSize),
                    painter: ArrowPainter(store.engineArrows.toList(), squareSize),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
