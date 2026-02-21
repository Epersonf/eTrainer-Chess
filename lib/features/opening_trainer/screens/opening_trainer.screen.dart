import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/features/opening_trainer/models/optrain_node.dart';
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

  @override
  void initState() {
    super.initState();
    store.loadRepertoire(_mockRepertoire());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Opening Trainer', style: GoogleFonts.michroma()),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            final boardWidget = Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 600,
                ),
                child: ChessBoard(
                  controller: store.chessController,
                  boardColor: BoardColor.brown,
                  boardOrientation: PlayerColor.white,
                  onMove: () {
                    // tente extrair o último movimento do controlador
                    try {
                      final history = store.chessController.game.history;
                      if (history.isNotEmpty) {
                        final lastMove = history.last.move;

                        final from = lastMove.fromAlgebraic;
                        final to = lastMove.toAlgebraic;
                        store.onUserMove(from, to);
                      }
                    } catch (_) {}
                  },
                ),
              ),
            );

            final panelWidget = _buildMessagePanel();

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(flex: 2, child: boardWidget),
                  Expanded(flex: 1, child: panelWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(flex: 2, child: boardWidget),
                  Expanded(flex: 1, child: panelWidget),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMessagePanel() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: const Border(left: BorderSide(color: Colors.cyan, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Observer(
            builder: (_) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.cyan, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      store.currentMessage,
                      style: GoogleFonts.ibmPlexSans(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Observer(
            builder: (_) {
              if (store.errorMessage == null) return const SizedBox.shrink();
              return Text(
                store.errorMessage!,
                style: GoogleFonts.ibmPlexSans(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Mock simples para demonstração
  OpTrainRepertoire _mockRepertoire() {
    return OpTrainRepertoire(
      initialFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      expectedMoves: {
        "e2e4": OpTrainNode(
          type: "MANUAL",
          possibleMessages: ["Ótimo! A abertura peão e4 domina o centro."],
          expectedMoves: {
            "e7e5": OpTrainNode(
              type: "AUTO",
              expectedMoves: {
                "g1f3": OpTrainNode(
                  type: "MANUAL",
                  possibleMessages: [
                    "Desenvolvendo o cavalo e atacando o peão em e5.",
                  ],
                  expectedMoves: {},
                ),
              },
            ),
            "c7c5": OpTrainNode(
              type: "AUTO",
              possibleMessages: ["Ah, o oponente escolheu a Siciliana!"],
              expectedMoves: {
                "g1f3": OpTrainNode(type: "MANUAL", expectedMoves: {}),
              },
            ),
          },
        ),
      },
    );
  }
}
