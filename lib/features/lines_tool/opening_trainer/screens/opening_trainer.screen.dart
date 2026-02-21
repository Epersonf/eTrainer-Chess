import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_trainer_chess/components/main_app_bar.dart';

// Components
import '../components/opening_board.dart';
import '../components/control_panel.dart';
import '../components/trainer_panel.dart';

@RoutePage()
class OpeningTrainerScreen extends StatefulWidget {
  const OpeningTrainerScreen({super.key});

  @override
  State<OpeningTrainerScreen> createState() => _OpeningTrainerScreenState();
}

class _OpeningTrainerScreenState extends State<OpeningTrainerScreen> {
  final OpeningTrainerStore store = sl<OpeningTrainerStore>();

  String _selectedOpening = 'italian';

  final Map<String, String> _defaultOpenings = {
    'italian': 'Italian Game',
    'london': 'London System',
    'english': 'English Opening',
    'sicilian': 'Sicilian Defense',
  };

  @override
  void initState() {
    super.initState();
    _loadAssetOpening(_selectedOpening);
  }

  @override
  void dispose() {
    store.dispose(); // Limpa o Store ao sair da tela
    super.dispose();
  }

  Future<void> _loadAssetOpening(String openingKey) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/openings/$openingKey.optrain',
      );
      final Object? decoded = jsonDecode(jsonString);

      if (decoded is Map) {
        final Map<String, Object?> jsonMap = Map<String, Object?>.from(decoded);
        final OpTrainRepertoire repertoire = OpTrainRepertoire.fromJson(
          jsonMap,
        );
        store.loadRepertoire(repertoire);
      }
    } catch (e) {
      // Log do erro real para você no console
      debugPrint("Erro ao carregar $openingKey: $e");
      store.currentMessage =
          "Erro ao carregar $openingKey. Verifique se o JSON é válido e existe.";
    }
  }

  Future<void> _pickAndLoadFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        String fileContents;
        if (result.files.single.bytes != null) {
          fileContents = utf8.decode(result.files.single.bytes!);
        } else {
          final File file = File(result.files.single.path!);
          fileContents = await file.readAsString();
        }

        final Object? decoded = jsonDecode(fileContents);
        if (decoded is Map) {
          final Map<String, Object?> jsonMap = Map<String, Object?>.from(
            decoded,
          );
          final OpTrainRepertoire repertoire = OpTrainRepertoire.fromJson(
            jsonMap,
          );

          setState(() => _selectedOpening = 'custom');
          store.loadRepertoire(repertoire);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar repertório: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepara os itens do dropdown uma vez por build
    final dropdownItems = [
      ..._defaultOpenings.entries.map((e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value, style: const TextStyle(color: Colors.white)),
          )),
      const DropdownMenuItem(
        value: 'custom',
        child: Text('Personalizado (.optrain)', style: TextStyle(color: Colors.cyanAccent)),
      ),
    ];

    // Scaffold com fundo Dark
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const MainAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;

              final boardWidget = OpeningBoard(store: store);
              final panelWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NOVO: Observer para atualizar o ícone do botão quando clicar
                  Observer(
                    builder: (_) => ControlPanel(
                      selectedOpening: _selectedOpening,
                      defaultOpenings: _defaultOpenings,
                      dropdownItems: dropdownItems,
                      onChanged: (val) {
                        if (val == null) return;
                        if (val == 'custom') {
                          _pickAndLoadFile();
                        } else {
                          setState(() => _selectedOpening = val);
                          _loadAssetOpening(val);
                        }
                      },
                      onRestart: store.restartTraining,
                      showCoordinates: store.showCoordinates,
                      onToggleCoordinates: store.toggleCoordinates,
                      playerMode: store.playerMode,
                      onModeChanged: store.setPlayerMode,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TrainerPanel(store: store),
                ],
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: boardWidget),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: panelWidget),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      boardWidget,
                      const SizedBox(height: 32),
                      panelWidget,
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
