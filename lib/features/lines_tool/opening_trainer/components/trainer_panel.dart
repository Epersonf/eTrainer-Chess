import 'package:e_trainer_chess/features/lines_tool/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainerPanel extends StatelessWidget {
  final OpeningTrainerStore store;

  const TrainerPanel({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology, color: Colors.cyanAccent, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  "Seu Treinador",
                  style: GoogleFonts.michroma(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(), // Empurra a lâmpada para a direita
                
                // NOVO: Botão de Lâmpada (Dica)
                Observer(
                  builder: (_) {
                    if (store.isTrainingFinished || store.hasMadeWrongMove || store.isAutoPlaying) {
                      return const SizedBox.shrink(); // Esconde se não for a vez do usuário
                    }
                    return IconButton(
                      icon: const Icon(Icons.lightbulb, color: Colors.amberAccent),
                      tooltip: "Mostrar Dica",
                      onPressed: store.showHint,
                    );
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Observer(
              builder: (_) => Text(
                store.currentMessage,
                style: GoogleFonts.ibmPlexSans(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
            Observer(
              builder: (_) {
                if (store.errorMessage == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            store.errorMessage!,
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // NOVO: Botão Desfazer aparece apenas se ele cometeu erro
                        if (store.hasMadeWrongMove) ...[
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.2),
                              foregroundColor: Colors.redAccent,
                              elevation: 0,
                              side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.undo, size: 16),
                            label: const Text("Desfazer"),
                            onPressed: store.undoWrongMove,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
