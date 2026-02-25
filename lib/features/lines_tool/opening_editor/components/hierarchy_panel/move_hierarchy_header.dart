import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';
import '../../services/stores/opening_editor.store.dart';

class MoveHierarchyHeader extends StatelessWidget {
  final OpeningEditorStore store;

  const MoveHierarchyHeader({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final locStore = sl<LocalizationStore>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
        color: Color(0xFF1A1A1A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                locStore.t('lineTool.editor.variant_tree'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Observer(
            builder: (_) => IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.undo, color: Colors.white70, size: 18),
              tooltip: locStore.t('lineTool.editor.undo_move'),
              onPressed: store.currentPath.isEmpty ? null : store.undoMove,
            ),
          ),
        ],
      ),
    );
  }
}
