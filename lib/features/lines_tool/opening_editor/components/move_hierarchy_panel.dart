import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/services/stores/opening_editor.store.dart';

class MoveHierarchyPanel extends StatelessWidget {
  final OpeningEditorStore store;

  const MoveHierarchyPanel({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: const Color(0xFF111111),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
              color: Color(0xFF1A1A1A),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_tree, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text("Variantes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                final List<Widget> items = [];
                Map<String, OpTrainNode>? currentMap = store.repertoire.expectedMoves;

                if (currentMap.isEmpty) {
                  return const Center(
                    child: Text("Faça o primeiro lance no tabuleiro.", style: TextStyle(color: Colors.white38)),
                  );
                }

                for (int i = 0; i <= store.currentPath.length; i++) {
                  if (currentMap == null || currentMap.isEmpty) break;

                  final bool isLast = i == store.currentPath.length;
                  final String? selectedMove = isLast ? null : store.currentPath[i];
                  final bool isCurrentActiveNode = selectedMove != null && i == store.currentPath.length - 1;

                  final int moveNumber = (i / 2).floor() + 1;
                  final String turnStr = i % 2 == 0 ? '$moveNumber.' : '$moveNumber...';

                  items.add(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCurrentActiveNode ? Colors.cyanAccent.withOpacity(0.1) : Colors.transparent,
                        border: isCurrentActiveNode
                          ? const Border(left: BorderSide(color: Colors.cyanAccent, width: 3))
                          : const Border(left: BorderSide(color: Colors.transparent, width: 3)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(turnStr, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedMove,
                                hint: const Text("Nova variante...", style: TextStyle(color: Colors.white24, fontSize: 13)),
                                isExpanded: true,
                                dropdownColor: const Color(0xFF2A2A2A),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 16),
                                style: TextStyle(
                                  color: isCurrentActiveNode ? Colors.cyanAccent : Colors.white70,
                                  fontWeight: isCurrentActiveNode ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                items: currentMap.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (newMove) {
                                  if (newMove != null && newMove != selectedMove) {
                                    store.switchVariation(i, newMove);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (selectedMove != null) {
                    currentMap = currentMap[selectedMove]?.expectedMoves;
                  }
                }

                return ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: items,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
