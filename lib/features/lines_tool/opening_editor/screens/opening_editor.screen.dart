import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/components/hierarchy_panel/move_hierarchy_panel.dart';
import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:e_trainer_chess/components/custom_chess_board/custom_chess_board.dart';

import 'package:e_trainer_chess/components/main_app_bar.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_editor/services/stores/opening_editor.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
        type: FileType
            .any, // Você pode restringir para extensões customizadas se preferir
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
          final Map<String, Object?> jsonMap = Map<String, Object?>.from(
            decoded,
          );
          final OpTrainRepertoire repertoire = OpTrainRepertoire.fromJson(
            jsonMap,
          );
          store.loadRepertoire(repertoire);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(sl<LocalizationStore>().t('lineTool.editor.line_loaded_success')),
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
            content: Text("${sl<LocalizationStore>().t('lineTool.editor.error_loading_file')} $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _exportLinetrain() async {
    final jsonText = store.exportJson();
    const fileName = 'my_repertoire.linetrain';
    
    debugPrint("===== SEU REPERTÓRIO (COPIE SE ALGO DER ERRADO) =====");
    debugPrint(jsonText);
    debugPrint("=====================================================");

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(jsonText);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final _ = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();

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
          SnackBar(
            content: Text(sl<LocalizationStore>().t('lineTool.editor.file_saved_success')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${sl<LocalizationStore>().t('lineTool.editor.error_saving')} $e"),
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
              tooltip: sl<LocalizationStore>().t('lineTool.editor.import_linetrain'),
              onPressed: _importLinetrain,
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.cyanAccent),
              tooltip: sl<LocalizationStore>().t('lineTool.editor.export_linetrain'),
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
                        constraints: const BoxConstraints(
                          maxWidth: 600,
                          maxHeight: 600,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: Colors.white10, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Observer(
                              builder: (_) => CustomChessBoard(
                                fen: store.currentFen,
                                isWhiteBottom: true,
                                showCoordinates: true,
                                onMove: (from, to, [promotion]) {
                                  store.onMoveMade(from, to, promotion);
                                },
                              ),
                            ),
                          ),
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
                              color: const material.Color.fromARGB(
                                255,
                                26,
                                26,
                                26,
                              ),
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
                            color: const material.Color.fromARGB(
                              255,
                              26,
                              26,
                              26,
                            ),
                            child: boardWidget,
                          ),
                          Expanded(child: MoveHierarchyPanel(store: store)),
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
