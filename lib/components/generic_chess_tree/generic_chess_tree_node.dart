import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class GenericChessTreeNode<T> extends StatefulWidget {
  final String moveKey;
  final String displayName;
  final List<String> path;
  final int depth;
  
  // Callback para o MobX: retorna o caminho atual para avaliar os destaques (cores)
  final List<String> Function() getActivePath;
  
  // Entradas filhas genéricas
  final List<MapEntry<String, T>> childrenEntries;
  
  // Eventos de clique
  final void Function(List<String> path) onTap;
  final void Function(List<String> path, Offset position)? onSecondaryTap;
  
  // Customizações Visuais (Usado pelo Editor de Linhas)
  final Color? Function(bool isExactlyActive, bool isAncestor)? getCustomTextColor;
  final Widget? trailingWidget;

  // Função recursiva que o Pai usa para ensinar ao componente como desenhar seus próprios filhos
  final Widget Function(MapEntry<String, T> childEntry, List<String> childPath, int childDepth) childBuilder;

  const GenericChessTreeNode({
    super.key,
    required this.moveKey,
    required this.displayName,
    required this.path,
    required this.getActivePath,
    required this.depth,
    required this.childrenEntries,
    required this.onTap,
    required this.childBuilder,
    this.onSecondaryTap,
    this.getCustomTextColor,
    this.trailingWidget,
  });

  @override
  State<GenericChessTreeNode<T>> createState() => _GenericChessTreeNodeState<T>();
}

class _GenericChessTreeNodeState<T> extends State<GenericChessTreeNode<T>> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final bool hasVariations = widget.childrenEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O Observer interno garante que apenas o NÓ que precisou mudar de cor re-renderize
        Observer(
          builder: (_) {
            final activePath = widget.getActivePath();
            final currentPathStr = activePath.join(',');
            final thisPathStr = widget.path.join(',');

            final isExactlyActive = currentPathStr == thisPathStr;
            final isAncestor = currentPathStr.startsWith('$thisPathStr,');

            final int moveNumber = (widget.depth ~/ 2) + 1;
            final String turnStr = widget.depth % 2 == 0 ? '$moveNumber.' : '$moveNumber...';

            final defaultColor = isExactlyActive 
                ? Colors.cyanAccent 
                : (isAncestor ? Colors.white : Colors.white54);
                
            final textColor = widget.getCustomTextColor?.call(isExactlyActive, isAncestor) ?? defaultColor;

            return GestureDetector(
              onTap: () => widget.onTap(widget.path),
              onSecondaryTapDown: widget.onSecondaryTap != null 
                  ? (details) => widget.onSecondaryTap!(widget.path, details.globalPosition) 
                  : null,
              child: Container(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(turnStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ),
                          Text(
                            widget.displayName,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isExactlyActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          if (widget.trailingWidget != null) ...[
                            const SizedBox(width: 8),
                            widget.trailingWidget!,
                          ],
                        ],
                      ),
                    ),
                    if (hasVariations)
                      GestureDetector(
                        onTap: () => setState(() => isExpanded = !isExpanded),
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
              ),
            );
          },
        ),
        
        // Chamada recursiva para desenhar os filhos
        if (isExpanded && hasVariations)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white10, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.childrenEntries.map((childEntry) {
                  final childPath = [...widget.path, childEntry.key];
                  return widget.childBuilder(childEntry, childPath, widget.depth + 1);
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
