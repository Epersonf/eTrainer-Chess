import 'package:flutter/material.dart';
import 'move_node_ui.dart';
import '../../services/stores/opening_editor.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';

class MoveTreeNode extends StatelessWidget {
  final OpeningEditorStore store;
  final String moveKey;
  final OpTrainNode node;
  final List<String> path;
  final int depth;

  const MoveTreeNode({
    super.key,
    required this.store,
    required this.moveKey,
    required this.node,
    required this.path,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoveNodeUI(
          store: store,
          moveKey: moveKey,
          node: node,
          path: path,
          depth: depth,
        ),
        if (node.expectedMoves != null && node.expectedMoves!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white10, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: node.expectedMoves!.entries.map((childEntry) {
                  return MoveTreeNode(
                    store: store,
                    moveKey: childEntry.key,
                    node: childEntry.value,
                    path: [...path, childEntry.key],
                    depth: depth + 1,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
