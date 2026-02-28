import 'package:flutter/material.dart';
import 'custom_chess_board.dart';

class PromotionDialog extends StatelessWidget {
  final String colorStr;

  const PromotionDialog({super.key, required this.colorStr});

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
