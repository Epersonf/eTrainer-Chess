import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';

class MoveListPanel extends StatelessWidget {
  final AnalysisStore store;
  const MoveListPanel({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Observer(
        builder: (_) {
          final moves = store.moveList;
          if (moves.isEmpty) {
            return const Center(child: Text('Nenhum lance.', style: TextStyle(color: Colors.white54)));
          }

          final movePairs = <Widget>[];
          // Organiza os lances em pares (Brancas, Pretas)
          for (int i = 0; i < moves.length; i += 2) {
            final moveNumber = (i ~/ 2) + 1;
            final whiteMove = moves[i];
            final blackMove = (i + 1 < moves.length) ? moves[i + 1] : '';

            movePairs.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('$moveNumber.', style: const TextStyle(color: Colors.white54))),
                    _MoveItem(move: whiteMove, index: i + 1, store: store),
                    const SizedBox(width: 16),
                    if (blackMove.isNotEmpty) _MoveItem(move: blackMove, index: i + 2, store: store),
                  ],
                ),
              )
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: movePairs,
          );
        },
      ),
    );
  }
}

class _MoveItem extends StatelessWidget {
  final String move;
  final int index; 
  final AnalysisStore store;

  const _MoveItem({required this.move, required this.index, required this.store});

  @override
  Widget build(BuildContext context) {
    final isSelected = store.currentMoveIndex == index;
    return GestureDetector(
      onTap: () => store.jumpToMove(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? Colors.cyan.withOpacity(0.5) : Colors.transparent),
        ),
        child: Text(
          move,
          style: TextStyle(
            color: isSelected ? Colors.cyanAccent : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
