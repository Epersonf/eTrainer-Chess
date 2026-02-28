import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:e_trainer_chess/components/main_app_bar.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';
import '../components/analysis_board.dart';
import '../components/analysis_controls.dart';
import '../components/analysis_tools.dart';
import '../components/engine_eval_panel.dart';
import '../components/analysis_tree_panel.dart';
import '../components/eval_bar.dart';

@RoutePage()
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisStore store = AnalysisStore();

  Future<void> _pickPgn() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.bytes != null) {
      final pgnData = utf8.decode(result.files.single.bytes!);
      final fileName = result.files.single.name; // Captura o nome do arquivo
      
      store.loadPgn(pgnData, fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: MainAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.amberAccent),
            tooltip: "Carregar PGN",
            onPressed: _pickPgn,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.cyanAccent),
            tooltip: "Exportar PGN Editado",
            onPressed: () {
              final pgnText = store.exportPgn();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('PGN gerado'),
                  content: SingleChildScrollView(child: SelectableText(pgnText)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pgnText));
                        Navigator.of(context).pop();
                      },
                      child: const Text('Copiar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LADO ESQUERDO: Tabuleiro e Controles
            Expanded(
              flex: 4, 
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Observer(
                          builder: (_) {
                            // Calcula dinamicamente o espaço com base na visibilidade da barra (28px de largura + 12px de margem)
                            double barWidth = store.showEngine ? 40.0 : 0.0;
                            double availableWidth = constraints.maxWidth - barWidth;
                            double availableHeight = constraints.maxHeight;
                            
                            // Força o tabuleiro a ser um quadrado perfeito considerando a barra ao lado
                            double boardSize = availableWidth < availableHeight ? availableWidth : availableHeight;

                            return Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (store.showEngine)
                                    SizedBox(
                                      height: boardSize,
                                      child: EvalBar(store: store),
                                    ),
                                  SizedBox(
                                    width: boardSize,
                                    height: boardSize,
                                    child: AnalysisBoard(store: store),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    )
                  ),
                  const SizedBox(height: 16),
                  AnalysisControls(store: store),
                ],
              )
            ),
            
            const SizedBox(width: 32),
            
            // LADO DIREITO: Painel de Ferramentas e Lista de Lances
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  AnalysisTools(store: store),
                  const SizedBox(height: 16),
                  // NOVO: Painel de Top Lances da Engine
                  EngineEvalPanel(store: store),
                  // O Expanded aqui é crucial para a ListView dos lances poder rolar
                  Expanded(
                    child: AnalysisTreePanel(store: store),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}