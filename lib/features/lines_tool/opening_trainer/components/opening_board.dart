import 'package:e_trainer_chess/features/lines_tool/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class OpeningBoard extends StatelessWidget {
  final OpeningTrainerStore store;

  const OpeningBoard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    // Estilo para destacar os caracteres por cima da textura do tabuleiro
    const coordStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 600,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Observer(
              builder: (_) {
                // A Orientação Visual agora depende estritamente da escolha do jogador
                final isWhiteBottom = store.playerMode != PlayerMode.black;
                
                return Stack(
                  children: [
                    ChessBoard(
                      controller: store.chessController,
                      boardColor: BoardColor.brown,
                      // Define a orientação usando o model do JSON
                      boardOrientation: isWhiteBottom ? PlayerColor.white : PlayerColor.black,
                      enableUserMoves: !store.isAutoPlaying && !store.hasMadeWrongMove,
                      onMove: () {
                        try {
                          final history = store.chessController.game.history;
                          if (history.isNotEmpty) {
                            final lastMove = history.last.move;
                            final String from = lastMove.fromAlgebraic;
                            final String to = lastMove.toAlgebraic;
                            
                            String? promotionStr;
                            if (lastMove.promotion != null) {
                              promotionStr = lastMove.promotion.toString().split('.').last.toLowerCase();
                              if (promotionStr.isNotEmpty) promotionStr = promotionStr[0];
                            }

                            store.onUserMove(from, to, promotionStr);
                          }
                        } catch (_) {}
                      },
                    ),
                    
                    // Overlay de Coordenadas independentes da lib
                    if (store.showCoordinates)
                      Positioned.fill(
                        child: IgnorePointer( // Impede as letras de bloquearem cliques nas peças
                          child: Stack(
                            children: [
                              // 1 a 8
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(8, (i) {
                                    final rank = isWhiteBottom ? 8 - i : i + 1;
                                    return Text(rank.toString(), style: coordStyle);
                                  }),
                                ),
                              ),
                              // a até h
                              Positioned(
                                bottom: 2,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(8, (i) {
                                    final file = isWhiteBottom 
                                        ? String.fromCharCode(97 + i) 
                                        : String.fromCharCode(104 - i);
                                    return Text(file, style: coordStyle);
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
