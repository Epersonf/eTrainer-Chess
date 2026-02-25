import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';
import 'move_tree_node.dart';
import '../../services/stores/opening_editor.store.dart';

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

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final locStore = sl<LocalizationStore>();
        if (widget.store.repertoire.expectedMoves.isEmpty) {
          return Center(
            child: Observer(
              builder: (_) => Text(
                locStore.t('lineTool.editor.make_first_move'),
                style: const TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.cyanAccent.withOpacity(0.5)),
              thickness: MaterialStateProperty.all(6),
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
                      children: widget.store.repertoire.expectedMoves.entries.map((entry) {
                        return MoveTreeNode(
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
      },
    );
  }
}
