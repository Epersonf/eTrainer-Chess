import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:e_trainer_chess/components/main_app_bar.dart';
import '../services/stores/analysis.store.dart';
import '../components/analysis_board.dart';

@RoutePage()
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisStore store = AnalysisStore();

  Future<void> _pickPgn() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.bytes != null) {
      final pgnData = utf8.decode(result.files.single.bytes!);
      store.loadPgn(pgnData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // Usando a sua AppBar e passando o botão de upload como ação extra!
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
            Expanded(
              flex: 4, 
              child: Column(
                children: [
                  // SOLUÇÃO DO OVERFLOW: Envolver o tabuleiro em um Expanded
                  Expanded(
                    child: AnalysisBoard(store: store),
                  ),
                  const SizedBox(height: 16),
                  // Controles de Navegação PGN
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
                          onPressed: store.prevMove,
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent),
                          onPressed: store.nextMove,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Observer(
                  builder: (_) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Ferramentas de Análise",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Mapa de Tensão (Hearthstone)", style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: store.showHeatmap,
                        activeColor: Colors.amber,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => store.toggleHeatmap(),
                      ),
                      const Divider(color: Colors.white10),
                      SwitchListTile(
                        title: const Text("Avaliação da Engine (Setas)", style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: store.showEngine,
                        activeColor: Colors.cyanAccent,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => store.toggleEngine(),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
