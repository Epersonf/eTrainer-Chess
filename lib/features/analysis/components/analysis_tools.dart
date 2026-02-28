import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';

class AnalysisTools extends StatelessWidget {
  final AnalysisStore store;
  const AnalysisTools({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              "Arquivo Carregado:",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              store.fileName,
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Text(
              "Ferramentas de Análise",
              style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Mapa de Tensão", style: TextStyle(color: Colors.white, fontSize: 14)),
              value: store.showHeatmap,
              activeColor: Colors.amber,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => store.toggleHeatmap(),
            ),
            const Divider(color: Colors.white10),
            SwitchListTile(
              title: const Text("Casas Fracas (Outposts)", style: TextStyle(color: Colors.white, fontSize: 14)),
              value: store.showWeakSquares,
              activeColor: Colors.purpleAccent,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => store.toggleWeakSquares(),
            ),
            const Divider(color: Colors.white10),
            SwitchListTile(
              title: const Text("Avaliação da Engine", style: TextStyle(color: Colors.white, fontSize: 14)),
              value: store.showEngine,
              activeColor: Colors.cyanAccent,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => store.toggleEngine(),
            ),
          ],
        ),
      ),
    );
  }
}
