import 'package:e_trainer_chess/features/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class OpeningBoard extends StatelessWidget {
  final OpeningTrainerStore store;

  const OpeningBoard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
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
              builder: (_) => ChessBoard(
                controller: store.chessController,
                boardColor: BoardColor.brown,
                boardOrientation: PlayerColor.white,
                enableUserMoves: !store.isAutoPlaying,
                onMove: () {
                  try {
                    final history = store.chessController.game.history;
                    if (history.isNotEmpty) {
                      final lastMove = history.last.move;
                      final String from = lastMove.fromAlgebraic;
                      final String to = lastMove.toAlgebraic;
                      
                      // Identifica se houve promoção e pega a primeira letra (q, r, b, n)
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
            ),
          ),
        ),
      ),
    );
  }
}