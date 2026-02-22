import 'package:flutter/material.dart';
import '../../services/stores/opening_editor.store.dart';

import 'move_hierarchy_header.dart';
import 'move_hierarchy_tree_scroll.dart';

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
