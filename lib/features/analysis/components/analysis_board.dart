import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';
import 'arrow_painter.dart';

class AnalysisBoard extends StatelessWidget {
  final AnalysisStore store;

  const AnalysisBoard({super.key, required this.store});

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
                    final stats = store.heatmapData[squareName];
                    final isUnderAttack = stats != null && stats.attacks > stats.defenses;

                    return Container(
                      color: isLightSquare ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
                      child: Stack(
                        children: [
                          if (store.showHeatmap && isUnderAttack)
                            Container(color: Colors.redAccent.withOpacity(0.4)),

                          const Center(
                            child: Text('♙', style: TextStyle(fontSize: 32, color: Colors.black)),
                          ),

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
                                      Text('${stats.defenses}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('${stats.attacks}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
