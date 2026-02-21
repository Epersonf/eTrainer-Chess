import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Permite adicionar botões extras à direita, como o botão de Exportar do Editor
  final List<Widget>? actions;

  const MainAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.cyanAccent),
      // Linha de detalhe ciano na base da App Bar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.cyanAccent.withOpacity(0.2),
          height: 1.0,
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo de forma sutil
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/logo.png',
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 24),
          
          // Dropdown "Line Tool"
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45), // Joga o menu para baixo da App Bar
              color: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              onSelected: (value) {
                // Navegação via auto_route
                if (value == 'editor') {
                  context.router.push(OpeningEditorRoute());
                } else if (value == 'trainer') {
                  context.router.push(OpeningTrainerRoute());
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Line Tool',
                    style: GoogleFonts.michroma(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'editor',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white70, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Editor',
                        style: GoogleFonts.ibmPlexSans(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'trainer',
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: Colors.white70, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Trainer',
                        style: GoogleFonts.ibmPlexSans(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  // Define a altura padrão de uma AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
