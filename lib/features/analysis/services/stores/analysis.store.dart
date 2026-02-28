import 'dart:convert';
import 'package:e_trainer_chess/features/analysis/utils/weak_squares_calculator.dart';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:chess/chess.dart' as chess_lib;

import '../../models/square_stats.dart';
import '../../models/engine_arrow.dart';
import '../../models/engine_evaluation.dart';
import '../../models/analysis_node.dart';
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
  ObservableMap<String, SquareStats> heatmapData =
      ObservableMap<String, SquareStats>();

  // NOVO: Set Reativo
  @observable
  ObservableSet<String> weakSquares = ObservableSet<String>();

  @observable
  ObservableList<EngineArrow> engineArrows = ObservableList<EngineArrow>();

  // NOVO: Lista das melhores linhas avaliadas
  @observable
  ObservableList<EngineEvaluation> topEvaluations =
      ObservableList<EngineEvaluation>();

  // NOVO: Valores numéricos e em texto da Vantagem p/ a Barra
  @observable
  double currentEvalScore = 0.0;

  @observable
  String currentEvalText = "0.00";

  // NOVO: Árvore de Variantes
  @observable
  ObservableMap<String, AnalysisNode> rootMoves =
      ObservableMap<String, AnalysisNode>();

  @observable
  ObservableList<String> currentPath = ObservableList<String>();

  @observable
  String startFen = chess_lib.Chess.DEFAULT_POSITION;

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
      topEvaluations.clear(); // Limpa as variantes quando desliga
      currentEvalScore = 0.0; // Reseta a barra
      currentEvalText = "0.00";
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
      if (char == '(') {
        parenDepth++;
        continue;
      }
      if (char == ')') {
        if (parenDepth > 0) parenDepth--;
        continue;
      }
      if (char == '{') {
        braceDepth++;
        continue;
      }
      if (char == '}') {
        if (braceDepth > 0) braceDepth--;
        continue;
      }
      if (char == '[') {
        bracketDepth++;
        continue;
      }
      if (char == ']') {
        if (bracketDepth > 0) bracketDepth--;
        continue;
      }

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

  @action
  void onMoveMade(String from, String to, [String? promotion]) {
    // No Dart, game.move retorna apenas um bool indicando sucesso.
    final bool moveResult = game.move({
      "from": from,
      "to": to,
      "promotion": promotion ?? 'q',
    });
    if (moveResult == false) return; // Lance inválido

    final String uciKey = promotion != null ? "$from$to$promotion" : "$from$to";

    // TRUQUE PARA EXTRAIR O SAN: Pegamos o PGN atualizado e limpamos tudo
    // igualzinho você fez no seu método `loadPgn`!
    String pgnText = game.pgn().replaceAll(RegExp(r'\[.*?\]\n*'), '');
    pgnText = pgnText.replaceAll(
      RegExp(r'\d+\.+'),
      '',
    ); // Remove os "1.", "2...", "1..."
    pgnText = pgnText
        .replaceAll('1-0', '')
        .replaceAll('0-1', '')
        .replaceAll('1/2-1/2', '')
        .replaceAll('*', '');

    final extractedMoves = pgnText
        .trim()
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty)
        .toList();

    // O último lance no array será o SAN (ex: "Nf3") que acabamos de fazer
    final String sanMove = extractedMoves.isNotEmpty
        ? extractedMoves.last
        : uciKey;
    final String newFen = game.fen;

    // Navega na árvore até a posição atual
    Map<String, AnalysisNode> currentMap = rootMoves;
    for (String step in currentPath) {
      currentMap = currentMap[step]!.variations;
    }

    // Se o lance não existe nesta posição, criamos uma nova ramificação
    if (!currentMap.containsKey(uciKey)) {
      currentMap[uciKey] = AnalysisNode(san: sanMove, fen: newFen);
    }

    // Atualiza o caminho atual e o FEN na store
    currentPath = ObservableList.of([...currentPath, uciKey]);
    currentFen = newFen;

    _applyCurrentState(); // Recalcula Heatmap, Weak Squares e Engine
  }

  @action
  void jumpToNode(List<String> path) {
    currentPath = ObservableList.of(path);
    game.load(startFen);
    for (String uci in path) {
      if (uci.length < 4) continue;
      final from = uci.substring(0, 2);
      final to = uci.substring(2, 4);
      final prom = uci.length > 4 ? uci.substring(4, 5) : 'q';
      game.move({"from": from, "to": to, "promotion": prom});
    }
    currentFen = game.fen;
    _applyCurrentState();
  }

  @action
  void undoMove() {
    if (currentPath.isNotEmpty) {
      final newPath = List<String>.from(currentPath)..removeLast();
      jumpToNode(newPath);
    }
  }

  String exportPgn() {
    StringBuffer pgn = StringBuffer();
    pgn.writeln('[Event "Analise E-Trainer"]');
    pgn.writeln('[Date "${DateTime.now().toIso8601String().split('T')[0]}"]');
    if (startFen != chess_lib.Chess.DEFAULT_POSITION) {
      pgn.writeln('[FEN "$startFen"]');
      pgn.writeln('[Setup "1"]');
    }
    pgn.writeln();

    void buildPgn(
      Map<String, AnalysisNode> moves,
      int moveNumber,
      bool isWhite,
      StringBuffer sb,
    ) {
      if (moves.isEmpty) return;

      final mainKey = moves.keys.first;
      final mainNode = moves[mainKey]!;

      if (isWhite)
        sb.write('$moveNumber. ');
      else if (sb.isEmpty)
        sb.write('$moveNumber... ');

      sb.write('${mainNode.san} ');

      if (mainNode.comment != null && mainNode.comment!.isNotEmpty) {
        sb.write('{ ${mainNode.comment} } ');
      }

      final variations = moves.keys.skip(1).toList();
      for (var vKey in variations) {
        sb.write('( ');
        final vNode = moves[vKey]!;
        if (isWhite)
          sb.write('$moveNumber. ');
        else
          sb.write('$moveNumber... ');
        sb.write('${vNode.san} ');
        buildPgn(
          vNode.variations,
          isWhite ? moveNumber : moveNumber + 1,
          !isWhite,
          sb,
        );
        sb.write(') ');
      }

      buildPgn(
        mainNode.variations,
        isWhite ? moveNumber : moveNumber + 1,
        !isWhite,
        sb,
      );
    }

    StringBuffer movesBuffer = StringBuffer();
    buildPgn(rootMoves, 1, true, movesBuffer);
    pgn.write(movesBuffer.toString().trim());
    return pgn.toString();
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
    topEvaluations.clear();
    final fenForEval = currentFen;

    try {
      final response = await http.post(
        Uri.parse('https://chess-api.com/v1'),
        headers: {'Content-Type': 'application/json'},
        // O segredo: "multipv: 3" pede ao stockfish as 3 melhores linhas!
        body: jsonEncode({'fen': fenForEval, 'depth': 12, 'multipv': 3}),
      );

      if (response.statusCode == 200) {
        if (currentFen != fenForEval)
          return; // FEN mudou enquanto a API pensava

        final data = jsonDecode(response.body);

        // A API retorna um Array se pedimos multipv. Mas previnimos falhas caso retorne objeto único.
        List<dynamic> evalList = data is List ? data : [data];
        List<EngineEvaluation> newEvals = [];

        bool isFirstMove = true; // Controla o "Top 1" lance

        for (var item in evalList) {
          final String? bestMove = item['move'] ?? item['bestmove'];
          if (bestMove == null || bestMove.length < 4) continue;

          final from = bestMove.substring(0, 2);
          final to = bestMove.substring(2, 4);
          final arrow = EngineArrow(from, to);

          String evalStr = "";

          if (item['mate'] != null) {
            int m = item['mate'];
            evalStr = m < 0 ? "-M${m.abs()}" : "M$m";

            if (isFirstMove) {
              currentEvalScore = m < 0
                  ? -10.0
                  : 10.0; // Força a barra no máximo pro lado que dá Mate
              currentEvalText = evalStr;
            }
          } else {
            double e = 0.0;
            try {
              e = (item['eval'] is int)
                  ? (item['eval'] as int).toDouble()
                  : (item['eval'] ?? 0.0).toDouble();
            } catch (_) {
              e = 0.0;
            }
            evalStr = e > 0 ? "+${e.toStringAsFixed(2)}" : e.toStringAsFixed(2);

            if (isFirstMove) {
              currentEvalScore = e;
              currentEvalText = evalStr;
            }
          }

          isFirstMove = false; // Garante que a barra não pegue os lances piores

          List<String> cont =
              (item['continuationArr'] as List<dynamic>?)?.cast<String>() ?? [];
          String sanLine = _buildSanLine(fenForEval, cont);

          newEvals.add(EngineEvaluation(evalStr, sanLine, arrow));
        }

        if (newEvals.isNotEmpty) {
          topEvaluations = ObservableList.of(newEvals);
          // Desenha a seta NO TABULEIRO apenas para o primeiro lance (o absoluto melhor)
          engineArrows = ObservableList.of([newEvals.first.arrow]);
        }
      }
    } catch (e) {
      print('Erro ao consultar a Engine: $e');
    }
  }

  // TRUQUE DE MESTRE: Simular os lances no Chess() pra formatar a linha toda automaticamente!
  String _buildSanLine(String startFen, List<String> uciMoves) {
    if (uciMoves.isEmpty) return "";
    final tempBoard = chess_lib.Chess()..load(startFen);

    for (String uci in uciMoves) {
      if (uci.length < 4) break;
      tempBoard.move({
        "from": uci.substring(0, 2),
        "to": uci.substring(2, 4),
        "promotion": uci.length > 4 ? uci[4] : 'q',
      });
    }

    // O PGN gera toda a string formatada! Só precisamos limpar o cabeçalho chato.
    String pgn = tempBoard.pgn();
    pgn = pgn.replaceAll(RegExp(r'\[.*?\]\n*'), '').trim();
    return pgn;
  }
}
