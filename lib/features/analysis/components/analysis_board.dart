import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/components/custom_chess_board.dart';
import '../services/stores/analysis.store.dart';

class AnalysisBoard extends StatelessWidget {
  final AnalysisStore store;

  const AnalysisBoard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return CustomChessBoard(
          fen: store.currentFen,
          isWhiteBottom: true,
          showCoordinates: true,
          heatmapData: store.showHeatmap ? store.heatmapData : null,
          arrows: store.showEngine ? store.engineArrows.toList() : null,
        );
      },
    );
  }
}