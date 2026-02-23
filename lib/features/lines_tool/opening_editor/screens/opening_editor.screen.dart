import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/components/hierarchy_panel/move_hierarchy_panel.dart';
import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_trainer_chess/components/main_app_bar.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/services/stores/opening_editor.store.dart';

@RoutePage()
@RoutePage()
class OpeningEditorScreen extends StatefulWidget {
  const OpeningEditorScreen({super.key});

  @override
  State<OpeningEditorScreen> createState() => _OpeningEditorScreenState();
}

class _OpeningEditorScreenState extends State<OpeningEditorScreen> {
  final OpeningEditorStore store = sl<OpeningEditorStore>();

  @override
  void initState() {
    super.initState();
    BrowserContextMenu.disableContextMenu();
  }

  @override
  void dispose() {
    store.dispose();
    BrowserContextMenu.enableContextMenu();
    super.dispose();
  }

  void _showExportDialog() {
    final jsonText = store.exportJson();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: material.Color.fromARGB(255, 30, 30, 30),
        title: Text(
          "JSON Exportado",
          style: GoogleFonts.michroma(color: Colors.cyanAccent),
        ),
        content: SingleChildScrollView(
          child: Text(
            jsonText,
            style: GoogleFonts.ibmPlexMono(color: Colors.white70, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copiado para a área de transferência!")),
              );
              Navigator.pop(context);
            },
            child: const Text("Copiar", style: TextStyle(color: Colors.cyanAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            store.undoMove();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            store.advanceMove();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: const material.Color.fromARGB(255, 18, 18, 18),
        appBar: MainAppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.cyanAccent),
              tooltip: "Exportar JSON",
              onPressed: _showExportDialog,
            ),
          ],
        ),
        body: Row(
          children: [
            // Painel da Esquerda (Tabuleiro + Editor de Mensagens)
            Expanded(
              flex: 5, 
              child: Container(
                padding: const EdgeInsets.all(24),
                color: const material.Color.fromARGB(255, 26, 26, 26),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 700;
            
                  final boardWidget = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                      child: ChessBoard(
                        controller: store.chessController,
                        boardColor: BoardColor.brown,
                        enableUserMoves: true,
                        onMove: () {
                          final history = store.chessController.game.history;
                          if (history.isNotEmpty) {
                            final lastMove = history.last.move;
                            String? promotionStr;
                            if (lastMove.promotion != null) {
                              promotionStr = lastMove.promotion.toString().split('.').last.toLowerCase();
                              if (promotionStr.isNotEmpty) promotionStr = promotionStr[0];
                            }
                            store.onMoveMade(
                              lastMove.fromAlgebraic,
                              lastMove.toAlgebraic,
                              promotionStr,
                            );
                          }
                        },
                      ),
                    ),
                  );

                  // Se for Desktop/Web divide a tela, senão empilha no mobile
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 4, 
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            color: const material.Color.fromARGB(255, 26, 26, 26),
                            child: boardWidget,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: MoveHierarchyPanel(store: store),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const material.Color.fromARGB(255, 26, 26, 26),
                          child: boardWidget,
                        ),
                        Expanded(
                          child: MoveHierarchyPanel(store: store),
                        ),
                      ],
                    );
                  }
                },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
