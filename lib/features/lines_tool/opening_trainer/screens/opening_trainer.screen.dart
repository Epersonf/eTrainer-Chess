import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:flutter/services.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
    'grunfeld': 'Grünfeld Defense',
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
        'assets/openings/$openingKey.linetrain', // <-- AQUI
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
      ..._defaultOpenings.entries.map(
        (e) => DropdownMenuItem(
          value: e.key,
          child: Text(e.value, style: const TextStyle(color: Colors.white)),
        ),
      ),
      DropdownMenuItem(
        value: 'custom',
        child: Text(
          sl<LocalizationStore>().t('lineTool.trainer.custom_linetrain'),
          style: const TextStyle(color: Colors.cyanAccent),
        ),
      ),
    ];

    // Scaffold com fundo Dark
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const MainAppBar(),
      body: SafeArea(
        // NOVO: Widget Focus captura cliques do teclado
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if ((store.canUndo || store.hasMadeWrongMove) &&
                    !store.isAutoPlaying) {
                  store.undoMove();
                }
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (store.canRedo && !store.isAutoPlaying) {
                  store.redoMove();
                }
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
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
                        variationMode: store.variationMode,
                        onVariationModeChanged: store.setVariationMode,
                        allowBadMoves: store.allowBadMoves,
                        onAllowBadMovesChanged: store.setAllowBadMoves,
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
                      // Envolver o panelWidget em SingleChildScrollView para evitar overflow vertical em janelas baixas
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(child: panelWidget),
                      ),
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
      ),
    );
  }
}
