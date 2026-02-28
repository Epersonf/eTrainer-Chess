import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:collection/collection.dart';
import '../services/stores/analysis.store.dart';
import '../models/analysis_node.dart';

class AnalysisTreePanel extends StatelessWidget {
  final AnalysisStore store;
  const AnalysisTreePanel({super.key, required this.store});

  Widget _buildNode(Map<String, AnalysisNode> moves, List<String> pathSoFar, AnalysisStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: moves.entries.map((entry) {
        final key = entry.key;
        final node = entry.value;
        final myPath = [...pathSoFar, key];
        final isCurrent = store.currentPath.length == myPath.length && ListEquality().equals(store.currentPath.toList(), myPath);

        return Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => store.jumpToNode(myPath),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.blueGrey[700] : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${node.san}', style: TextStyle(color: isCurrent ? Colors.white : Colors.white70)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (store.rootMoves.isEmpty) {
        return const Center(child: Text('Nenhuma variação', style: TextStyle(color: Colors.white54)));
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildNode(store.rootMoves, [], store),
        ),
      );
    });
  }
}
