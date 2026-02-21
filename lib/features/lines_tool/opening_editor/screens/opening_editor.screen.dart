import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/components/node_graph.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/services/stores/opening_editor.store.dart';
import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

@RoutePage()
class OpeningEditorScreen extends StatefulWidget {
  const OpeningEditorScreen({super.key});

  @override
  State<OpeningEditorScreen> createState() => _OpeningEditorScreenState();
}

class _OpeningEditorScreenState extends State<OpeningEditorScreen> {
  final OpeningEditorStore store = sl<OpeningEditorStore>();
  final TextEditingController _messagesController = TextEditingController();

  @override
  void dispose() {
    store.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  void _showExportDialog() {
    final jsonText = store.exportJson();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: material.Color.fromARGB(255, 30, 30, 30),
        title: Text("JSON Exportado", style: GoogleFonts.michroma(color: Colors.cyanAccent)),
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
    return Scaffold(
      backgroundColor: const material.Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        title: Text('Opening Editor', style: GoogleFonts.michroma(color: Colors.cyanAccent)),
        backgroundColor: const material.Color.fromARGB(255, 26, 26, 26),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.cyanAccent),
            tooltip: "Exportar JSON",
            onPressed: _showExportDialog,
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            color: const material.Color.fromARGB(255, 26, 26, 26),
            child: Column(
              children: [
                ChessBoard(
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
                      store.onMoveMade(lastMove.fromAlgebraic, lastMove.toAlgebraic, promotionStr);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Editor de Nó", style: GoogleFonts.michroma(color: Colors.white, fontSize: 14)),
                    Observer(
                      builder: (_) => IconButton(
                        icon: const Icon(Icons.undo, color: Colors.grey),
                        onPressed: store.currentPath.isEmpty ? null : store.undoMove,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Observer(
                    builder: (_) {
                      if (store.currentPath.isEmpty) {
                        return Center(child: Text("Faça um lance para editar.", style: TextStyle(color: Colors.grey[600])));
                      }

                      if (_messagesController.text != store.currentMessagesInput && !FocusScope.of(context).hasFocus) {
                        _messagesController.text = store.currentMessagesInput;
                      }

                      return TextField(
                        controller: _messagesController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Adicione mensagens (uma por linha)...",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          filled: true,
                          fillColor: const material.Color.fromARGB(255, 44, 44, 44),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: store.saveMessages,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) => NodeGraph(
                rootMoves: store.repertoire.expectedMoves,
                currentPath: store.currentPath,
                onNodeTap: store.jumpToNode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
