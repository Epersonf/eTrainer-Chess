import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../services/stores/analysis.store.dart';
import 'arrow_painter.dart';

class AnalysisBoard extends StatelessWidget {
  final AnalysisStore store;

  const AnalysisBoard({super.key, required this.store});

  // Mapeamento do tipo da biblioteca para o nome do arquivo
  static const pieceNameMap = {
    'p': 'pawn',
    'n': 'knight',
    'b': 'bishop',
    'r': 'rook',
    'q': 'queen',
    'k': 'king',
  };

  @override
  Widget build(BuildContext context) {
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
                    final int rank = 8 - (index ~/ 8);
                    final int file = index % 8;
                    final String squareName = '${String.fromCharCode(97 + file)}$rank';
                    final bool isLightSquare = (rank + file) % 2 != 0;

                    return Observer(builder: (_) {
                      final _ = store.currentFen; 
                      final stats = store.heatmapData[squareName];
                      final isUnderAttack = stats != null && stats.attacks > stats.defenses;
                      final chess_lib.Piece? piece = store.game.get(squareName);
                      
                      Widget pieceWidget = const SizedBox.shrink();

                      // LÓGICA DAS IMAGENS PNG ATUALIZADA
                      if (piece != null) {
                        // Pega a cor por extenso para bater com o nome da pasta e prefixo do arquivo
                        final colorStr = piece.color == chess_lib.Color.WHITE ? 'white' : 'black';
                        final pieceName = pieceNameMap[piece.type.toLowerCase()];
                        
                        // Monta o caminho exato: ex. 'assets/pieces/black/black-rook.png'
                        final assetPath = 'assets/pieces/$colorStr/$colorStr-$pieceName.png';

                        pieceWidget = Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                        );
                      }

                      return Container(
                        color: isLightSquare ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
                        child: Stack(
                          children: [
                            if (store.showHeatmap && isUnderAttack)
                              Container(color: Colors.redAccent.withOpacity(0.4)),
                            
                            // Adiciona um respiro de 4px para a peça não colar na borda da casa
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(child: pieceWidget),
                            ),

                            if (store.showHeatmap && stats != null)
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
      ),
    );
  }

  Widget _buildBadge(IconData icon, int value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
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