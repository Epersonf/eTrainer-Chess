import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../services/stores/opening_editor.store.dart';

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
