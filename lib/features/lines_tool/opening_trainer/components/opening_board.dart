import 'package:e_trainer_chess/features/lines_tool/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/components/custom_chess_board/custom_chess_board.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';

class OpeningBoard extends StatelessWidget {
  final OpeningTrainerStore store;

  const OpeningBoard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              builder: (_) {
                final isWhiteBottom = store.playerMode != PlayerMode.black;
                
                return Stack(
                  children: [
                    CustomChessBoard(
                      fen: store.currentFen,
                      isWhiteBottom: isWhiteBottom,
                      showCoordinates: store.showCoordinates,
                      onMove: (store.isAutoPlaying || store.hasMadeWrongMove)
                          ? null
                          : (from, to, [promotion]) => store.onUserMove(from, to, promotion),
                    ),
                    
                    // (Overlay de coordenadas removido — agora o CustomChessBoard desenha as coordenadas)
                    // NOVO: Overlay de Seleção de Variante (quando store.pendingVariations não for nulo)
                    if (store.pendingVariations != null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.75),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    sl<LocalizationStore>().t('lineTool.trainer.choose_variation'),
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...store.pendingVariations!.entries.map((entry) {
                                    final moveKey = entry.key;
                                    final node = entry.value;
                                    final displayName = node.name ?? "${sl<LocalizationStore>().t('lineTool.trainer.variant')} ${moveKey.substring(0, 2)}-${moveKey.substring(2, 4)}";

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const material.Color(0xFF2C2C2C),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              side: const BorderSide(color: Colors.white24),
                                            ),
                                          ),
                                          onPressed: () => store.chooseVariation(moveKey),
                                          child: Text(displayName, style: const TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
