// lib/components/main_app_bar.dart
import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Permite adicionar botões extras à direita, como o botão de Exportar do Editor
  final List<Widget>? actions;

  const MainAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    final locStore = sl<LocalizationStore>();

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
          
          const SizedBox(width: 32), // Espaçamento entre as opções
          
          // NOVO: Botão Independente para Analysis
          InkWell(
            onTap: () => context.router.push(AnalysisRoute()),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.analytics, color: Colors.cyanAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Analysis',
                    style: GoogleFonts.michroma(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        IconButton(
          icon: const Icon(Icons.language, color: Colors.cyanAccent),
          tooltip: 'Alterar Idioma',
          onPressed: () => _showLanguageModal(context, locStore),
        ),
      ],
    );
  }

  void _showLanguageModal(BuildContext context, LocalizationStore store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Observer(
                  builder: (_) => Text(
                    store.t('select_language'),
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              ...store.availableLanguages.map((lang) {
                return Observer(
                  builder: (_) {
                    final isSelected = store.currentLocale == lang['code'];
                    return ListTile(
                      leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        lang['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.cyanAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.cyanAccent) : null,
                      onTap: () {
                        store.setLocale(lang['code']!);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Define a altura padrão de uma AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
