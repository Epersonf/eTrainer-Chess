import 'dart:convert';
import 'package:e_trainer_chess/features/analysis/utils/weak_squares_calculator.dart';
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

  // NOVO: Controle de Casas Fracas
  @observable
  bool showWeakSquares = false;

  @observable
  ObservableMap<String, SquareStats> heatmapData = ObservableMap<String, SquareStats>();

  // NOVO: Set Reativo
  @observable
  ObservableSet<String> weakSquares = ObservableSet<String>();

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

  // NOVO: Toggle
  @action
  void toggleWeakSquares() {
    showWeakSquares = !showWeakSquares;
    if (showWeakSquares) _calculateWeakSquares();
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
    
    // Parser seguro baseado em profundidade para remover comentários e variantes aninhadas
    StringBuffer sb = StringBuffer();
    int parenDepth = 0;
    int braceDepth = 0;
    int bracketDepth = 0;

    for (int i = 0; i < fullPgnText.length; i++) {
      String char = fullPgnText[i];
      if (char == '(') { parenDepth++; continue; }
      if (char == ')') { if (parenDepth > 0) parenDepth--; continue; }
      if (char == '{') { braceDepth++; continue; }
      if (char == '}') { if (braceDepth > 0) braceDepth--; continue; }
      if (char == '[') { bracketDepth++; continue; }
      if (char == ']') { if (bracketDepth > 0) bracketDepth--; continue; }

      if (parenDepth == 0 && braceDepth == 0 && bracketDepth == 0) {
        sb.write(char);
      }
    }

    fullPgnText = sb.toString();
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
    if (showWeakSquares) _calculateWeakSquares(); // <-- ADICIONADO
    if (showEngine) _requestEngineEval();
  }

  // --- O SEGREDO DESMOCKADO AQUI --- //

  void _calculateHeatmap() {
    heatmapData.clear();
    final realStats = HeatmapCalculator.calculate(currentFen);
    heatmapData.addAll(realStats);
  }

  // NOVO: Calculador
  void _calculateWeakSquares() {
    weakSquares.clear();
    weakSquares.addAll(WeakSquaresCalculator.getWeakSquares(currentFen));
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
