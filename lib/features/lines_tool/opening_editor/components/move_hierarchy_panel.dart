import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import '../services/stores/opening_editor.store.dart';

class MoveHierarchyPanel extends StatelessWidget {
  final OpeningEditorStore store;

  const MoveHierarchyPanel({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_tree, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text("Árvore de Variantes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Observer(
                  builder: (_) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.undo, color: Colors.white70, size: 18),
                    tooltip: "Voltar um lance",
                    onPressed: store.currentPath.isEmpty ? null : store.undoMove,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (store.repertoire.expectedMoves.isEmpty) {
                  return const Center(
                    child: Text("Faça o primeiro lance", style: TextStyle(color: Colors.white38)),
                  );
                }
                
                // Scroll duplo (Vertical e Horizontal)
                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      // Mantém a largura mínima igual à do painel para o background preencher tudo
                      constraints: const BoxConstraints(minWidth: 320),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: store.repertoire.expectedMoves.entries.map((entry) {
                            return _MoveTreeNode(
                              store: store,
                              moveKey: entry.key,
                              node: entry.value,
                              path: [entry.key],
                              depth: 0,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveTreeNode extends StatelessWidget {
  final OpeningEditorStore store;
  final String moveKey;
  final OpTrainNode node;
  final List<String> path;
  final int depth;

  const _MoveTreeNode({
    required this.store,
    required this.moveKey,
    required this.node,
    required this.path,
    required this.depth,
  });

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: const Color(0xFF2A2A2A),
      items: [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.redAccent, size: 18),
              SizedBox(width: 8),
              Text("Deletar Variante", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') store.deleteNode(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPathStr = store.currentPath.join(',');
    final thisPathStr = path.join(',');
    
    final isExactlyActive = currentPathStr == thisPathStr;
    final isAncestor = currentPathStr.startsWith('$thisPathStr,');
    
    // Lógica unificada para saber se o lance faz parte do caminho atual
    final isActivePath = isExactlyActive || isAncestor;

    final int moveNumber = (depth / 2).floor() + 1;
    final String turnStr = depth % 2 == 0 ? '$moveNumber.' : '$moveNumber...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => store.jumpToNode(path),
          onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // Usa o isActivePath para colorir toda a linha da variante
              color: isActivePath ? Colors.cyanAccent.withOpacity(0.15) : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isActivePath ? Colors.cyanAccent : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(turnStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                Text(
                  moveKey,
                  style: TextStyle(
                    // Letra realçada em toda a variante ativa
                    color: isActivePath ? Colors.cyanAccent : Colors.white70,
                    fontWeight: isActivePath ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16), // Espaçador para empurrar o chat
                if (node.possibleMessages != null && node.possibleMessages!.isNotEmpty)
                  const Icon(Icons.chat_bubble, color: Colors.white24, size: 12),
              ],
            ),
          ),
        ),
        
        // Renderiza os filhos com "Nesting" visual
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
                  return _MoveTreeNode(
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