import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/components/hierarchy_panel/move_hierarchy_panel.dart';
import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

import 'package:e_trainer_chess/components/main_app_bar.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/services/stores/opening_editor.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';

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

  Future<void> _importLinetrain() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Você pode restringir para extensões customizadas se preferir
      );

      if (result != null) {
        String fileContents;
        if (result.files.single.bytes != null) {
          fileContents = utf8.decode(result.files.single.bytes!);
        } else {
          final File file = File(result.files.single.path!);
          fileContents = await file.readAsString();
        }

        final Object? decoded = jsonDecode(fileContents);
        if (decoded is Map) {
          final Map<String, Object?> jsonMap = Map<String, Object?>.from(decoded);
          final OpTrainRepertoire repertoire = OpTrainRepertoire.fromJson(jsonMap);
          store.loadRepertoire(repertoire);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Linha carregada com sucesso!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar arquivo: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _exportLinetrain() async {
    final jsonText = store.exportJson();
    const fileName = 'my_repertoire.linetrain';

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(jsonText);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.Url.revokeObjectUrl(url);
      } else {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Salvar Linha de Treino',
          fileName: fileName,
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonText);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Arquivo salvo com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
              icon: const Icon(Icons.upload_file, color: Colors.amberAccent),
              tooltip: "Importar .linetrain",
              onPressed: _importLinetrain,
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.cyanAccent),
              tooltip: "Exportar .linetrain",
              onPressed: _exportLinetrain,
            ),
          ],
        ),
        // ... (resto do LayoutBuilder que divide a tela fica idêntico ao que já ajustamos na etapa anterior)

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
