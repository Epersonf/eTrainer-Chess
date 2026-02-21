import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:e_trainer_chess/features/opening_trainer/models/optrain_repertoire.dart';
import 'package:e_trainer_chess/features/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

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
  };

  @override
  void initState() {
    super.initState();
    _loadAssetOpening(_selectedOpening);
  }

  Future<void> _loadAssetOpening(String openingKey) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/openings/$openingKey.optrain');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final repertoire = OpTrainRepertoire.fromJson(jsonMap);
      store.loadRepertoire(repertoire);
    } catch (e) {
      store.currentMessage = "Erro ao carregar $openingKey. Verifique se o arquivo existe em assets/openings/";
    }
  }

  Future<void> _pickAndLoadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        String fileContents;
        if (result.files.single.bytes != null) {
          fileContents = utf8.decode(result.files.single.bytes!);
        } else {
          File file = File(result.files.single.path!);
          fileContents = await file.readAsString();
        }

        final Map<String, dynamic> jsonMap = jsonDecode(fileContents);
        final repertoire = OpTrainRepertoire.fromJson(jsonMap);
        
        setState(() {
          _selectedOpening = 'custom';
        });
        store.loadRepertoire(repertoire);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Opening Trainer', style: GoogleFonts.michroma(color: Colors.white)),
        elevation: 4,
        shadowColor: Colors.black54,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              
              final boardWidget = _buildBoard();
              final panelWidget = _buildControlPanel();

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: boardWidget),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: panelWidget),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      boardWidget,
                      const SizedBox(height: 24),
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

  Widget _buildBoard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 600,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Observer(
              builder: (_) => ChessBoard(
                controller: store.chessController,
                boardColor: BoardColor.brown,
                boardOrientation: PlayerColor.white,
                // Bloqueia movimentos do usuário enquanto a máquina joga
                enableUserMoves: !store.isAutoPlaying,
                onMove: () {
                  try {
                    final history = store.chessController.game.history;
                    if (history.isNotEmpty) {
                      final lastMove = history.last.move;
                      store.onUserMove(lastMove.fromAlgebraic, lastMove.toAlgebraic);
                    }
                  } catch (_) {}
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seletor de Aberturas
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Escolha o Repertório",
                  style: GoogleFonts.ibmPlexSans(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedOpening,
                          items: [
                            ..._defaultOpenings.entries.map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value, style: const TextStyle(color: Colors.white)),
                                )),
                            const DropdownMenuItem(
                              value: 'custom',
                              child: Text('Personalizado (.optrain)', style: TextStyle(color: Colors.cyan)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            if (val == 'custom') {
                              _pickAndLoadFile();
                            } else {
                              setState(() => _selectedOpening = val);
                              _loadAssetOpening(val);
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.cyan),
                      tooltip: "Reiniciar Treino",
                      onPressed: store.restartTraining,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Painel do Treinador (Mensagens)
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.cyan, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      "Seu Treinador",
                      style: GoogleFonts.ibmPlexSans(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 32),
                Observer(
                  builder: (_) => Text(
                    store.currentMessage,
                    style: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                ),
                Observer(
                  builder: (_) {
                    if (store.errorMessage == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        store.errorMessage!,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}