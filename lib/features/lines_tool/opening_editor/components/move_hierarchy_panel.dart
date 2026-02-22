import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import '../services/stores/opening_editor.store.dart';

/// 1. CONTAINER PRINCIPAL
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
          MoveHierarchyHeader(store: store),
          Expanded(
            child: MoveHierarchyTreeScroll(store: store),
          ),
        ],
      ),
    );
  }
}

/// 2. CABEÇALHO DO PAINEL
class MoveHierarchyHeader extends StatelessWidget {
  final OpeningEditorStore store;

  const MoveHierarchyHeader({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                "Árvore de Variantes",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
    );
  }
}

/// 3. SISTEMA DE SCROLL DUPLO EXPLÍCITO
class MoveHierarchyTreeScroll extends StatefulWidget {
  final OpeningEditorStore store;

  const MoveHierarchyTreeScroll({super.key, required this.store});

  @override
  State<MoveHierarchyTreeScroll> createState() => _MoveHierarchyTreeScrollState();
}

class _MoveHierarchyTreeScrollState extends State<MoveHierarchyTreeScroll> {
  // Controladores independentes e explícitos
  final ScrollController _verticalCtrl = ScrollController();
  final ScrollController _horizontalCtrl = ScrollController();

  @override
  void dispose() {
    _verticalCtrl.dispose();
    _horizontalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (widget.store.repertoire.expectedMoves.isEmpty) {
          return const Center(
            child: Text("Faça o primeiro lance", style: TextStyle(color: Colors.white38)),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(Colors.cyanAccent.withOpacity(0.5)),
              thickness: WidgetStateProperty.all(6),
              radius: const Radius.circular(10),
            ),
          ),
          // O SEGREDO ESTÁ AQUI: Ambas as Scrollbars ficam ancoradas "por fora" dos ScrollViews.
          // Assim elas ficam presas à tela, não ao fim do conteúdo infinito.
          child: Scrollbar(
            controller: _horizontalCtrl,
            thumbVisibility: true,
            // Permite que o scrollbar capture o evento mesmo estando níveis acima na árvore
            notificationPredicate: (notif) => notif.depth >= 0, 
            child: Scrollbar(
              controller: _verticalCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalCtrl,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _horizontalCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    // Padding inferior extra para a barra horizontal não sobrepor o último texto
                    padding: const EdgeInsets.fromLTRB(8, 8, 32, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.store.repertoire.expectedMoves.entries.map((entry) {
                        return MoveTreeNode(
                          store: widget.store,
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
            ),
          ),
        );
      },
    );
  }
}

/// 4. CONSTRUTOR RECURSIVO DA ÁRVORE (Layout)
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

/// 5. COMPONENTE VISUAL DO LANCE (Lógica isolada de Highlight)
class MoveNodeUI extends StatelessWidget {
  final OpeningEditorStore store;
  final String moveKey;
  final OpTrainNode node;
  final List<String> path;
  final int depth;

  const MoveNodeUI({
    super.key,
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

    // LÓGICA DE ESTADO SEPARADA RIGOROSAMENTE
    // 1. O lance exato onde o usuário parou
    final isExactlyActive = currentPathStr == thisPathStr;
    // 2. Os lances que o usuário fez até chegar ao ponto atual (histórico da variante)
    final isAncestor = currentPathStr.startsWith('$thisPathStr,');

    final int moveNumber = (depth / 2).floor() + 1;
    final String turnStr = depth % 2 == 0 ? '$moveNumber.' : '$moveNumber...';

    return GestureDetector(
      onTap: () => store.jumpToNode(path),
      onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2), // Espaço sutil entre as linhas
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // O BACKGROUND CIANO FICA APENAS NO LANCE EXATO ATUAL
          color: isExactlyActive ? Colors.cyanAccent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4), // Bordas arredondadas para não vazar a cor feito escada infinita
          border: Border(
            left: BorderSide(
              // Borda ciano forte pro lance ativo, ciano fraco para o histórico, invisível pro resto
              color: isExactlyActive 
                  ? Colors.cyanAccent 
                  : (isAncestor ? Colors.cyan.withOpacity(0.5) : Colors.transparent),
              width: 3,
            ),
          ),
        ),
        // MainAxisSize.min força o background a "abraçar" apenas o texto, resolvendo o bug visual da escada super larga
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: Text(turnStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            Text(
              moveKey,
              style: TextStyle(
                // Branco vivo para o caminho ativo, cinza apagado para as outras variantes
                color: isExactlyActive 
                    ? Colors.cyanAccent 
                    : (isAncestor ? Colors.white : Colors.white54),
                fontWeight: isExactlyActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            if (node.possibleMessages != null && node.possibleMessages!.isNotEmpty)
              const Icon(Icons.chat_bubble, color: Colors.white24, size: 12),
          ],
        ),
      ),
    );
  }
}