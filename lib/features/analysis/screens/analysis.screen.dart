import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:e_trainer_chess/components/main_app_bar.dart';
import '../services/stores/analysis.store.dart';
import '../components/analysis_board.dart';
import '../components/analysis_controls.dart';
import '../components/analysis_tools.dart';
import '../components/move_list_panel.dart';

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
                  // O Expanded + Center garante que o AspectRatio do AnalysisBoard 
                  // consiga calcular o quadrado perfeito sem dar overflow.
                  Expanded(
                    child: Center(
                      child: AnalysisBoard(store: store),
                    ),
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
                  // O Expanded aqui é crucial para a ListView dos lances poder rolar
                  Expanded(
                    child: MoveListPanel(store: store),
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