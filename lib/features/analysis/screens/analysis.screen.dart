import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
      appBar: AppBar(
        title: const Text("Analysis Board"),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.cyanAccent),
            tooltip: "Carregar PGN",
            onPressed: _pickPgn,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(flex: 2, child: AnalysisBoard(store: store)),
            const SizedBox(width: 32),
            Expanded(
              flex: 1,
              child: Observer(
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text("Hearthstone Heatmap", style: TextStyle(color: Colors.white)),
                      value: store.showHeatmap,
                      activeColor: Colors.amber,
                      onChanged: (val) => store.toggleHeatmap(),
                    ),
                    SwitchListTile(
                      title: const Text("Engine Arrows", style: TextStyle(color: Colors.white)),
                      value: store.showEngine,
                      activeColor: Colors.cyanAccent,
                      onChanged: (val) => store.toggleEngine(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
