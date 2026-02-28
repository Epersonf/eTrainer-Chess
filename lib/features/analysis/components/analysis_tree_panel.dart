import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../components/generic_chess_tree/generic_chess_tree_node.dart';
import '../services/stores/analysis.store.dart';
import '../models/analysis_node.dart';

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

  // O builder que passa as regras específicas da "AnalysisNode" para o Nó Genérico
  Widget _buildNode(MapEntry<String, AnalysisNode> entry, List<String> path, int depth) {
    return GenericChessTreeNode<AnalysisNode>(
      key: ValueKey(path.join(',')),
      moveKey: entry.key,
      displayName: entry.value.san, // Na Análise, mostramos apenas o SAN
      path: path,
      getActivePath: () => widget.store.currentPath.toList(),
      depth: depth,
      childrenEntries: entry.value.variations.entries.toList(),
      onTap: (p) => widget.store.jumpToNode(p),
      // Recursividade: aponta para esta mesma função
      childBuilder: (childEntry, childPath, childDepth) => _buildNode(childEntry, childPath, childDepth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (widget.store.rootMoves.isEmpty) {
        return const Center(child: Text('Nenhuma variação', style: TextStyle(color: Colors.white54)));
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 32, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.store.rootMoves.entries.map((entry) {
                      return _buildNode(entry, [entry.key], 0);
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