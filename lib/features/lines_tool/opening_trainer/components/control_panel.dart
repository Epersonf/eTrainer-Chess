import 'package:e_trainer_chess/features/lines_tool/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlPanel extends StatelessWidget {
  final String selectedOpening;
  final Map<String, String> defaultOpenings;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRestart;
  final bool showCoordinates;
  final VoidCallback onToggleCoordinates;

  // NOVO: Adicionado controles de Modo
  final PlayerMode playerMode;
  final ValueChanged<PlayerMode> onModeChanged;
  // NOVO: Seletor de variação (Random / Select)
  final VariationMode variationMode;
  final ValueChanged<VariationMode> onVariationModeChanged;
  
  // NOVO: Flags de filtro de lances
  final bool allowBadMoves;
  final ValueChanged<bool> onAllowBadMovesChanged;

  const ControlPanel({
    super.key,
    required this.selectedOpening,
    required this.defaultOpenings,
    this.dropdownItems,
    required this.onChanged,
    required this.onRestart,
    required this.showCoordinates,
    required this.onToggleCoordinates,
    required this.playerMode,
    required this.onModeChanged,
    required this.variationMode,
    required this.onVariationModeChanged,
    required this.allowBadMoves,
    required this.onAllowBadMovesChanged,
  });

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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Repertório de Aberturas",
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Botão de Coordenadas
                InkWell(
                  onTap: onToggleCoordinates,
                  child: Row(
                    children: [
                      Icon(
                        showCoordinates ? Icons.grid_on : Icons.grid_off,
                        color: showCoordinates
                            ? Colors.cyanAccent
                            : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Coords",
                        style: TextStyle(
                          color: showCoordinates
                              ? Colors.cyanAccent
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2C2C2C),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.cyanAccent,
                        ),
                        value: selectedOpening,
                        items:
                            dropdownItems ??
                            [
                              ...defaultOpenings.entries.map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const DropdownMenuItem(
                                value: 'custom',
                                child: Text(
                                  'Personalizado (.linetrain)',
                                  style: TextStyle(color: Colors.cyanAccent),
                                ),
                              ),
                            ],
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
                    tooltip: "Reiniciar Treino",
                    onPressed: onRestart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Text(
              "Seleção de Variante (Engine):",
              style: GoogleFonts.ibmPlexSans(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 16),
            Text(
              "Filtros da Engine:",
              style: GoogleFonts.ibmPlexSans(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 8),
            
            // NOVO: Apenas um checkbox direto ao ponto
            CheckboxListTile(
              title: const Text("Permitir Lances Ruins (Armadilhas)", style: TextStyle(color: Colors.white, fontSize: 12)),
              value: allowBadMoves,
              onChanged: (val) => onAllowBadMovesChanged(val ?? false),
              activeColor: Colors.redAccent,
              checkColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => onVariationModeChanged(VariationMode.random),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: variationMode == VariationMode.random
                              ? Colors.cyanAccent.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: variationMode == VariationMode.random
                              ? Border.all(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                )
                              : null,
                        ),
                        child: const Center(
                          child: Text(
                            "Random",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () => onVariationModeChanged(VariationMode.select),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: variationMode == VariationMode.select
                              ? Colors.cyanAccent.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: variationMode == VariationMode.select
                              ? Border.all(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                )
                              : null,
                        ),
                        child: const Center(
                          child: Text(
                            "Select",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // NOVO: Seletor de Modo (Brancas / Ambas / Pretas)
            Text(
              "Jogar de:",
              style: GoogleFonts.ibmPlexSans(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildModeButton(
                    title: "Brancas",
                    mode: PlayerMode.white,
                    iconColor: Colors.white,
                  ),
                  _buildModeButton(
                    title: "Ambas",
                    mode: PlayerMode.both,
                    iconColor: Colors.grey,
                  ),
                  _buildModeButton(
                    title: "Pretas",
                    mode: PlayerMode.black,
                    iconColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required PlayerMode mode,
    required Color iconColor,
  }) {
    final isSelected = playerMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => onModeChanged(mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.cyanAccent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.cyanAccent.withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: iconColor, size: 12),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.cyanAccent : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
