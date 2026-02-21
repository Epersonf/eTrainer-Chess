import 'package:e_trainer_chess/features/opening_trainer/models/optrain_node.dart';
import 'package:flutter/material.dart';

class NodeGraph extends StatelessWidget {
  final Map<String, OpTrainNode> rootMoves;
  final List<String> currentPath;
  final Function(List<String> path) onNodeTap;

  const NodeGraph({
    super.key,
    required this.rootMoves,
    required this.currentPath,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.1,
      maxScale: 2.0,
      constrained: false,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: _buildTree(rootMoves, []),
      ),
    );
  }

  Widget _buildTree(Map<String, OpTrainNode>? moves, List<String> pathToHere) {
    if (moves == null || moves.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: moves.entries.map((entry) {
        final moveKey = entry.key;
        final node = entry.value;
        final thisPath = [...pathToHere, moveKey];

        final isSelected = currentPath.join(',') == thisPath.join(',');
        final isAncestor = currentPath.length > thisPath.length &&
            currentPath.sublist(0, thisPath.length).join(',') == thisPath.join(',');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 32.0),
              child: GestureDetector(
                onTap: () => onNodeTap(thisPath),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.cyanAccent.withOpacity(0.2)
                        : isAncestor
                            ? Colors.grey[800]
                            : const Color(0xFF2C2C2C),
                    border: Border.all(
                      color: isSelected ? Colors.cyanAccent : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    moveKey,
                    style: TextStyle(
                      color: isSelected ? Colors.cyanAccent : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            if (node.expectedMoves != null && node.expectedMoves!.isNotEmpty)
              _buildTree(node.expectedMoves, thisPath),
          ],
        );
      }).toList(),
    );
  }
}
