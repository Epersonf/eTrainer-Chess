import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlPanel extends StatelessWidget {
  final String selectedOpening;
  final Map<String, String> defaultOpenings;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRestart;
  // NOVO: Recebendo os parâmetros das coordenadas
  final bool showCoordinates;
  final VoidCallback onToggleCoordinates;

  const ControlPanel({
    super.key,
    required this.selectedOpening,
    required this.defaultOpenings,
    this.dropdownItems,
    required this.onChanged,
    required this.onRestart,
    required this.showCoordinates,
    required this.onToggleCoordinates,
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
            Text(
              "Repertório de Aberturas",
              style: GoogleFonts.ibmPlexSans(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                        value: selectedOpening,
                        items: dropdownItems ?? [
                          ...defaultOpenings.entries.map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(color: Colors.white)),
                              )),
                          const DropdownMenuItem(
                            value: 'custom',
                            child: Text('Personalizado (.optrain)', style: TextStyle(color: Colors.cyanAccent)),
                          ),
                        ],
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // NOVO: Botão de toggle das coordenadas
                Container(
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      showCoordinates ? Icons.grid_on : Icons.grid_off,
                      color: showCoordinates ? Colors.cyanAccent : Colors.grey,
                    ),
                    tooltip: "Mostrar Coordenadas",
                    onPressed: onToggleCoordinates,
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
          ],
        ),
      ),
    );
  }
}
