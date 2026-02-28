import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:chess/chess.dart' as chess_lib;

import '../../models/square_stats.dart';
import '../../models/engine_arrow.dart';
import '../../utils/heatmap_calculator.dart';

part 'analysis.store.g.dart';

class AnalysisStore = AnalysisStoreBase with _$AnalysisStore;

abstract class AnalysisStoreBase with Store {
  final chess_lib.Chess game = chess_lib.Chess();
  List<String> _fensHistory = [chess_lib.Chess.DEFAULT_POSITION];

  @observable
  int currentMoveIndex = 0;

  @observable
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;

  @observable
  String fileName = 'Nenhum arquivo';

  @observable
  ObservableList<String> moveList = ObservableList<String>();

  @observable
  bool showHeatmap = true;

  @observable
  bool showEngine = false;

  @observable
  ObservableMap<String, SquareStats> heatmapData = ObservableMap<String, SquareStats>();

  @observable
  ObservableList<EngineArrow> engineArrows = ObservableList<EngineArrow>();

  @action
  void toggleHeatmap() {
    showHeatmap = !showHeatmap;
    if (showHeatmap) _calculateHeatmap();
  }

  @action
  void toggleEngine() {
    showEngine = !showEngine;
    if (showEngine) {
      _requestEngineEval();
    } else {
      engineArrows.clear();
    }
  }

  @action
  void loadPgn(String pgn, String name) {
    final cleanPgn = pgn.replaceAll('\r\n', '\n').trim();
    final tempGame = chess_lib.Chess();

    if (!tempGame.load_pgn(cleanPgn)) {
      fileName = "Erro: Arquivo PGN inválido";
      moveList.clear();
      return;
    }

    fileName = name;
    engineArrows.clear();

    String fullPgnText = tempGame.pgn();
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\[.*?\]'), '');
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\{.*?\}'), '');
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\(.*?\)'), '');
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\d+\.'), '');
    fullPgnText = fullPgnText
        .replaceAll('1-0', '')
        .replaceAll('0-1', '')
        .replaceAll('1/2-1/2', '')
        .replaceAll('*', '');

    final extractedMoves = fullPgnText
        .trim()
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty)
        .toList();

    moveList.clear();
    moveList.addAll(extractedMoves);

    final replayGame = chess_lib.Chess();
    final List<String> fens = [replayGame.fen];

    for (var moveStr in extractedMoves) {
      replayGame.move(moveStr);
      fens.add(replayGame.fen);
    }

    _fensHistory = fens;
    currentMoveIndex = 0;
    _applyCurrentState();
  }

  @action
  void prevMove() {
    if (currentMoveIndex > 0) {
      currentMoveIndex--;
      _applyCurrentState();
    }
  }

  @action
  void nextMove() {
    if (currentMoveIndex < _fensHistory.length - 1) {
      currentMoveIndex++;
      _applyCurrentState();
    }
  }

  @action
  void jumpToMove(int index) {
    if (index >= 0 && index < _fensHistory.length) {
      currentMoveIndex = index;
      _applyCurrentState();
    }
  }

  void _applyCurrentState() {
    currentFen = _fensHistory[currentMoveIndex];
    game.load(currentFen);

    if (showHeatmap) _calculateHeatmap();
    if (showEngine) _requestEngineEval();
  }

  // --- O SEGREDO DESMOCKADO AQUI --- //

  void _calculateHeatmap() {
    heatmapData.clear();
    final realStats = HeatmapCalculator.calculate(currentFen);
    heatmapData.addAll(realStats);
  }

  Future<void> _requestEngineEval() async {
    engineArrows.clear();
    final fenForEval = currentFen;

    try {
      final response = await http.post(
        Uri.parse('https://chess-api.com/v1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fen': fenForEval, 'depth': 12}),
      );

      if (response.statusCode == 200) {
        if (currentFen != fenForEval) return;

        final data = jsonDecode(response.body);
        final String bestMove = data['bestmove'];

        if (bestMove.isNotEmpty && bestMove.length >= 4) {
          final from = bestMove.substring(0, 2);
          final to = bestMove.substring(2, 4);
          engineArrows = ObservableList.of([EngineArrow(from, to)]);
        }
      }
    } catch (e) {
      print('Erro ao consultar a Engine: $e');
    }
  }
}
