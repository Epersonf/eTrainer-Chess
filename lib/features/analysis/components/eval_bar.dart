import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../services/stores/analysis.store.dart';

class EvalBar extends StatelessWidget {
  final AnalysisStore store;
  const EvalBar({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        double score = store.currentEvalScore;
        
        // Limitamos visualmente o range a -8.0 até +8.0 para que vantagens extremas 
        // apenas "esmaguem" a barra sem quebrá-la.
        double clampedScore = score.clamp(-8.0, 8.0);
        
        // Fórmula de proporção: 50% (equilíbrio) + variação baseada no score
        double whitePercent = 0.5 + (clampedScore / 16.0);
        whitePercent = whitePercent.clamp(0.05, 0.95); // Mantém no mínimo 5% visível
        double blackPercent = 1.0 - whitePercent;

        bool whiteAdvantage = score >= 0;

        return Container(
          width: 28, // Largura da barra
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24, width: 1),
            color: const Color(0xFF1E1E1E), // Fundo base
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Column(
              children: [
                // Vantagem das Pretas (Topo da barra)
                Expanded(
                  flex: (blackPercent * 1000).toInt(),
                  child: Container(
                    color: const Color(0xFF333333), // Cinza escuro/Preto
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 6),
                    child: !whiteAdvantage
                        ? Text(
                            store.currentEvalText.replaceAll('-', ''), // Remove o sinal de menos pro visual
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                // Vantagem das Brancas (Base da barra)
                Expanded(
                  flex: (whitePercent * 1000).toInt(),
                  child: Container(
                    color: Colors.white, // Branco brilhante
                    width: double.infinity,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 6),
                    child: whiteAdvantage
                        ? Text(
                            store.currentEvalText.replaceAll('+', ''), // Remove o sinal de mais
                            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
