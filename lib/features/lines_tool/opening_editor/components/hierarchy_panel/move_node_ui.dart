import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../services/stores/opening_editor.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import '../message_editor_modal.dart';

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

  void _showRenameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: node.name ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Renomear Variante", style: TextStyle(color: Colors.cyanAccent)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Nome (ex: Abertura Peão Rei)",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              store.renameNodeByPath(path, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final isGood = node.quality == MoveQuality.good; // NOVO
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: const Color(0xFF2A2A2A),
      items: [
        const PopupMenuItem(
          value: 'messages',
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.amberAccent, size: 18),
              SizedBox(width: 8),
              Text("Editar Mensagens", style: TextStyle(color: Colors.amberAccent)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blueAccent, size: 18),
              SizedBox(width: 8),
              Text("Renomear Variante", style: TextStyle(color: Colors.blueAccent)),
            ],
          ),
        ),
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

        // NOVO: Toggle Quality
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'toggle_quality',
          child: Row(
            children: [
              Icon(isGood ? Icons.thumb_down : Icons.thumb_up, color: isGood ? Colors.redAccent : Colors.greenAccent, size: 18),
              const SizedBox(width: 8),
              Text(isGood ? "Marcar como Lance Ruim" : "Marcar como Lance Bom", style: TextStyle(color: isGood ? Colors.redAccent : Colors.greenAccent)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') store.deleteNode(path);
      if (value == 'rename') _showRenameDialog(context);
      if (value == 'toggle_quality') store.toggleNodeQuality(path); // NOVO
      if (value == 'messages') {
        store.jumpToNode(path);
        showDialog(
          context: context,
          builder: (ctx) => MessageEditorModal(store: store, moveKey: moveKey),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final activePath = store.currentPath.toList();
        final currentPathStr = activePath.join(',');
        final thisPathStr = path.join(',');

        final isExactlyActive = currentPathStr == thisPathStr;
        final isAncestor = currentPathStr.startsWith('$thisPathStr,');

        final int moveNumber = (depth / 2).floor() + 1;
        final String turnStr = depth % 2 == 0 ? '$moveNumber.' : '$moveNumber...';

        // Lógica de exibição do nome
        String displayName = moveKey;
        if (node.name != null && node.name!.isNotEmpty) {
          displayName = "$moveKey - ${node.name}";
        }

        final isBadMove = node.quality == MoveQuality.bad; // NOVO

        return GestureDetector(
          onTap: () => store.jumpToNode(path),
          onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                SizedBox(
                  width: 32,
                  child: Text(turnStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                Flexible( // Evita quebra de layout se o nome for muito longo
                  child: Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      // NOVO: Se for ruim, fica vermelho pálido (a menos que seja o ativo, que fica vermelho forte)
                      color: isExactlyActive
                          ? (isBadMove ? Colors.redAccent : Colors.cyanAccent)
                          : (isAncestor 
                              ? (isBadMove ? Colors.red[300] : Colors.white) 
                              : (isBadMove ? Colors.red[900] : Colors.white54)),
                      fontWeight: isExactlyActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (node.possibleMessages != null && node.possibleMessages!.isNotEmpty)
                  const Icon(Icons.chat_bubble, color: Colors.white24, size: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}