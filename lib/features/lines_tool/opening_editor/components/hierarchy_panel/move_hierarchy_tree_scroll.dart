import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';
import '../../../../../components/generic_chess_tree/generic_chess_tree_node.dart';
import '../../services/stores/opening_editor.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import '../message_editor_modal.dart';

class MoveHierarchyTreeScroll extends StatefulWidget {
  final OpeningEditorStore store;
  const MoveHierarchyTreeScroll({super.key, required this.store});

  @override
  State<MoveHierarchyTreeScroll> createState() => _MoveHierarchyTreeScrollState();
}

class _MoveHierarchyTreeScrollState extends State<MoveHierarchyTreeScroll> {
  final ScrollController _verticalCtrl = ScrollController();
  final ScrollController _horizontalCtrl = ScrollController();

  @override
  void dispose() {
    _verticalCtrl.dispose();
    _horizontalCtrl.dispose();
    super.dispose();
  }

  // Regras do Context Menu do Editor
  void _showContextMenu(BuildContext context, Offset position, List<String> path, OpTrainNode node, String moveKey) {
    final isGood = node.quality == MoveQuality.good;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: const Color(0xFF2A2A2A),
      items: [
        PopupMenuItem(
          value: 'messages',
          child: Row(children: [const Icon(Icons.chat_bubble_outline, color: Colors.amberAccent, size: 18), const SizedBox(width: 8), Text(sl<LocalizationStore>().t('lineTool.editor.edit_messages'), style: const TextStyle(color: Colors.amberAccent))]),
        ),
        PopupMenuItem(
          value: 'rename',
          child: Row(children: [const Icon(Icons.edit, color: Colors.blueAccent, size: 18), const SizedBox(width: 8), Text(sl<LocalizationStore>().t('lineTool.editor.rename_variant'), style: const TextStyle(color: Colors.blueAccent))]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [const Icon(Icons.delete, color: Colors.redAccent, size: 18), const SizedBox(width: 8), Text(sl<LocalizationStore>().t('lineTool.editor.delete_variant'), style: const TextStyle(color: Colors.redAccent))]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'toggle_quality',
          child: Row(children: [Icon(isGood ? Icons.thumb_down : Icons.thumb_up, color: isGood ? Colors.redAccent : Colors.greenAccent, size: 18), const SizedBox(width: 8), Text(isGood ? sl<LocalizationStore>().t('lineTool.editor.mark_bad_move') : sl<LocalizationStore>().t('lineTool.editor.mark_good_move'), style: TextStyle(color: isGood ? Colors.redAccent : Colors.greenAccent))]),
        ),
      ],
    ).then((value) {
      if (value == 'delete') widget.store.deleteNode(path);
      if (value == 'rename') _showRenameDialog(context, path, node);
      if (value == 'toggle_quality') widget.store.toggleNodeQuality(path);
      if (value == 'messages') {
        widget.store.jumpToNode(path);
        showDialog(context: context, builder: (ctx) => MessageEditorModal(store: widget.store, moveKey: moveKey));
      }
    });
  }

  void _showRenameDialog(BuildContext context, List<String> path, OpTrainNode node) {
    final TextEditingController controller = TextEditingController(text: node.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(sl<LocalizationStore>().t('lineTool.editor.rename_variant'), style: const TextStyle(color: Colors.cyanAccent)),
        content: TextField(
          controller: controller, autofocus: true, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(filled: true, fillColor: const Color(0xFF2A2A2A)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(sl<LocalizationStore>().t('common.cancel'), style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              widget.store.renameNodeByPath(path, controller.text);
              Navigator.pop(ctx);
            },
            child: Text(sl<LocalizationStore>().t('common.save'), style: const TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  // O builder que traduz o "OpTrainNode" para o Nó Genérico
  Widget _buildEditorNode(MapEntry<String, OpTrainNode> entry, List<String> path, int depth) {
    final node = entry.value;
    final moveKey = entry.key;
    
    String displayName = moveKey;
    if (node.name != null && node.name!.isNotEmpty) {
      displayName = "$moveKey - ${node.name}";
    }

    final isBadMove = node.quality == MoveQuality.bad;

    return GenericChessTreeNode<OpTrainNode>(
      key: ValueKey(path.join(',')),
      moveKey: moveKey,
      displayName: displayName,
      path: path,
      getActivePath: () => widget.store.currentPath.toList(),
      depth: depth,
      childrenEntries: node.expectedMoves?.entries.toList() ?? [],
      onTap: (p) => widget.store.jumpToNode(p),
      onSecondaryTap: (p, pos) => _showContextMenu(context, pos, p, node, moveKey),
      // Lógica de cores baseada em Lances Ruins (Bad Moves)
      getCustomTextColor: (isActive, isAncestor) {
        if (isActive) return isBadMove ? Colors.redAccent : Colors.cyanAccent;
        if (isAncestor) return isBadMove ? Colors.red[300] : Colors.white;
        return isBadMove ? Colors.red[900] : Colors.white54;
      },
      // Balão de Chat visual se tiver mensagem configurada
      trailingWidget: (node.possibleMessages != null && node.possibleMessages!.isNotEmpty)
          ? const Icon(Icons.chat_bubble, color: Colors.white24, size: 12)
          : null,
      childBuilder: (childEntry, childPath, childDepth) => _buildEditorNode(childEntry, childPath, childDepth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final locStore = sl<LocalizationStore>();
        if (widget.store.repertoire.expectedMoves.isEmpty) {
          return Center(child: Text(locStore.t('lineTool.editor.make_first_move'), style: const TextStyle(color: Colors.white38)));
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
            controller: _horizontalCtrl, thumbVisibility: true, notificationPredicate: (notif) => notif.depth >= 0,
            child: Scrollbar(
              controller: _verticalCtrl, thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalCtrl, scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _horizontalCtrl, scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 32, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.store.repertoire.expectedMoves.entries.map((entry) {
                        return _buildEditorNode(entry, [entry.key], 0);
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
