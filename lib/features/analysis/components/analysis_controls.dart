import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';

class AnalysisControls extends StatelessWidget {
  final AnalysisStore store;
  const AnalysisControls({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      // O Observer aqui é importante para desabilitar a setinha de voltar 
      // quando estivermos no início da árvore
      child: Observer( 
        builder: (_) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
              // Se o caminho estiver vazio (posição inicial), desabilita o botão
              onPressed: store.currentPath.isEmpty ? null : store.undoMove,
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent),
              // Usa a nova função de avançar pelas ramificações
              onPressed: store.advanceMove, 
            ),
          ],
        ),
      ),
    );
  }
}