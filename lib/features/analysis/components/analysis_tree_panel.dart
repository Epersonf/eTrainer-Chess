import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';
import '../models/analysis_node.dart';

// 1. PAINEL PRINCIPAL COM SCROLL DUPLO
class AnalysisTreePanel extends StatefulWidget {
  final AnalysisStore store;
  const AnalysisTreePanel({super.key, required this.store});

  @override
  State<AnalysisTreePanel> createState() => _AnalysisTreePanelState();
}

class _AnalysisTreePanelState extends State<AnalysisTreePanel> {
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
    return Observer(builder: (_) {
      if (widget.store.rootMoves.isEmpty) {
        return const Center(
          child: Text(
            'Nenhuma variação',
            style: TextStyle(color: Colors.white54),
          ),
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
        child: Scrollbar(
          controller: _horizontalCtrl,
          thumbVisibility: true,
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
                  // Dá um respiro à direita e embaixo para não colar no scroll
                  padding: const EdgeInsets.fromLTRB(8, 8, 32, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.store.rootMoves.entries.map((entry) {
                      return AnalysisTreeNode(
                        key: ValueKey(entry.key),
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
    });
  }
}

// 2. NÓ RECURSIVO (AGORA STATEFUL PARA SER COLAPSÁVEL)
class AnalysisTreeNode extends StatefulWidget {
  final AnalysisStore store;
  final String moveKey;
  final AnalysisNode node;
  final List<String> path;
  final int depth;

  const AnalysisTreeNode({
    super.key,
    required this.store,
    required this.moveKey,
    required this.node,
    required this.path,
    required this.depth,
  });

  @override
  State<AnalysisTreeNode> createState() => _AnalysisTreeNodeState();
}

class _AnalysisTreeNodeState extends State<AnalysisTreeNode> {
  bool isExpanded = true; // Por padrão, a árvore nasce aberta

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalysisNodeUI(
          store: widget.store,
          moveKey: widget.moveKey,
          node: widget.node,
          path: widget.path,
          depth: widget.depth,
          isExpanded: isExpanded,
          onToggleExpanded: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
        ),
        
        // Só desenha os filhos se estiver com "isExpanded == true"
        if (isExpanded && widget.node.variations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white10, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.node.variations.entries.map((childEntry) {
                  final childPath = [...widget.path, childEntry.key];
                  return AnalysisTreeNode(
                    // Passar a Key é importante pro Flutter não se perder ao abrir/fechar as árvores
                    key: ValueKey(childPath.join(',')),
                    store: widget.store,
                    moveKey: childEntry.key,
                    node: childEntry.value,
                    path: childPath,
                    depth: widget.depth + 1,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

// 3. UI VISUAL DO LANCE
class AnalysisNodeUI extends StatelessWidget {
  final AnalysisStore store;
  final String moveKey;
  final AnalysisNode node;
  final List<String> path;
  final int depth;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const AnalysisNodeUI({
    super.key,
    required this.store,
    required this.moveKey,
    required this.node,
    required this.path,
    required this.depth,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final currentPathStr = store.currentPath.join(',');
        final thisPathStr = path.join(',');

        final isExactlyActive = currentPathStr == thisPathStr;
        final isAncestor = currentPathStr.startsWith('$thisPathStr,');

        final int moveNumber = (depth ~/ 2) + 1;
        final String turnStr = depth % 2 == 0 ? '$moveNumber.' : '$moveNumber...';
        final bool hasVariations = node.variations.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isExactlyActive ? Colors.cyanAccent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(
                color: isExactlyActive
                    ? Colors.cyanAccent
                    : (isAncestor ? Colors.cyan.withOpacity(0.5) : Colors.transparent),
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Área clicável principal (pular para o lance)
              GestureDetector(
                onTap: () => store.jumpToNode(path),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(turnStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ),
                      Text(
                        node.san,
                        style: TextStyle(
                          color: isExactlyActive
                              ? Colors.cyanAccent
                              : (isAncestor ? Colors.white : Colors.white54),
                          fontWeight: isExactlyActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botão de expandir/colapsar (Apenas se tiver ramificações filhas)
              if (hasVariations)
                GestureDetector(
                  onTap: onToggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: Colors.cyanAccent.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}