import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:chess/chess.dart' as chess_lib;

import '../../models/square_stats.dart';
import '../../models/engine_arrow.dart';
import '../../models/engine_evaluation.dart';
import '../../models/analysis_node.dart';
import '../../utils/heatmap_calculator.dart';
import '../../utils/weak_squares_calculator.dart';

part 'analysis.store.g.dart';

class AnalysisStore = AnalysisStoreBase with _$AnalysisStore;

abstract class AnalysisStoreBase with Store {
  final chess_lib.Chess game = chess_lib.Chess();

  @observable
  String fileName = 'Nenhum arquivo';

  @observable
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;

  @observable
  bool showHeatmap = true;

  @observable
  bool showEngine = false;

  @observable
  bool showWeakSquares = false;

  @observable
  ObservableMap<String, SquareStats> heatmapData = ObservableMap<String, SquareStats>();

  @observable
  ObservableSet<String> weakSquares = ObservableSet<String>();

  @observable
  ObservableList<EngineArrow> engineArrows = ObservableList<EngineArrow>();

  @observable
  ObservableList<EngineEvaluation> topEvaluations = ObservableList<EngineEvaluation>();

  @observable
  double currentEvalScore = 0.0;

  @observable
  String currentEvalText = "0.00";

  // --- NOVA ESTRUTURA DE ÁRVORE DE VARIANTES ---
  @observable
  ObservableMap<String, AnalysisNode> rootMoves = ObservableMap<String, AnalysisNode>();

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
      topEvaluations.clear(); 
      currentEvalScore = 0.0; 
      currentEvalText = "0.00";
    }
  }

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
      rootMoves.clear();
      currentPath.clear();
      return;
    }

    fileName = name;
    engineArrows.clear();

    String fullPgnText = tempGame.pgn();

    // Parser seguro para remover comentários e variantes aninhadas da linha principal
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

    // LÓGICA DE CONSTRUÇÃO DA ÁRVORE (Linha Principal do PGN)
    rootMoves.clear();
    currentPath.clear();
    
    final replayGame = chess_lib.Chess();
    startFen = replayGame.fen; // Guarda o FEN inicial
    
    Map<String, AnalysisNode> currentMap = rootMoves;
    List<String> builtPath = [];

    for (var sanMove in extractedMoves) {
      replayGame.move(sanMove); 
      
      final newNode = AnalysisNode(
        san: sanMove,
        fen: replayGame.fen,
      );
      
      currentMap[sanMove] = newNode;
      currentMap = newNode.variations; // Avança o ponteiro do mapa para os filhos
      builtPath.add(sanMove);
    }

    currentPath = ObservableList.of(builtPath);
    currentFen = replayGame.fen;
    
    _applyCurrentState();
  }

  @action
  void onMoveMade(String from, String to, [String? promotion]) {
    // 1. O Dart chess_lib retorna apenas boolean no game.move()
    final bool moveResult = game.move({
      "from": from,
      "to": to,
      "promotion": promotion ?? 'q',
    });
    if (moveResult == false) return; // Lance inválido

    // 2. Extrair o lance em notação SAN (ex: Nf3) gerando o PGN atual e pegando o último lance
    String pgnText = game.pgn().replaceAll(RegExp(r'\[.*?\]\n*'), '');
    pgnText = pgnText.replaceAll(RegExp(r'\d+\.+'), ''); 
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

    // O último lance é o SAN correspondente ao move que acabamos de fazer
    final String sanMove = extractedMoves.isNotEmpty ? extractedMoves.last : "${from}${to}";
    final String newFen = game.fen;

    // 3. Navega na árvore para o nó atual baseado no currentPath
    Map<String, AnalysisNode> currentMap = rootMoves;
    for (String step in currentPath) {
      currentMap = currentMap[step]!.variations;
    }

    // 4. Insere a ramificação caso ainda não exista
    if (!currentMap.containsKey(sanMove)) {
      currentMap[sanMove] = AnalysisNode(san: sanMove, fen: newFen);
    }

    // 5. Atualiza os estados de navegação
    currentPath = ObservableList.of([...currentPath, sanMove]);
    currentFen = newFen;

    _applyCurrentState();
  }

  @action
  void jumpToNode(List<String> path) {
    currentPath = ObservableList.of(path);
    game.load(startFen);
    
    for (String moveSan in path) {
      game.move(moveSan); // Como a chave da árvore agora é o SAN (Nf3), o move() aceita direto!
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

  @action
  void advanceMove() {
    Map<String, AnalysisNode> currentMap = rootMoves;
    for (String step in currentPath) {
      currentMap = currentMap[step]?.variations ?? {};
    }

    if (currentMap.isNotEmpty) {
      // Pega o primeiro lance (a linha principal) daquela ramificação
      final nextMove = currentMap.keys.first;
      jumpToNode([...currentPath, nextMove]);
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

      if (isWhite) {
        sb.write('$moveNumber. ');
      } else if (sb.isEmpty || sb.toString().endsWith('( ')) {
        sb.write('$moveNumber... ');
      }

      sb.write('${mainNode.san} ');

      if (mainNode.comment != null && mainNode.comment!.isNotEmpty) {
        sb.write('{ ${mainNode.comment} } ');
      }

      final variations = moves.keys.skip(1).toList();
      for (var vKey in variations) {
        sb.write('( ');
        final vNode = moves[vKey]!;
        if (isWhite) {
          sb.write('$moveNumber. ');
        } else {
          sb.write('$moveNumber... ');
        }
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

  void _applyCurrentState() {
    if (showHeatmap) _calculateHeatmap();
    if (showWeakSquares) _calculateWeakSquares();
    if (showEngine) _requestEngineEval();
  }

  void _calculateHeatmap() {
    heatmapData.clear();
    final realStats = HeatmapCalculator.calculate(currentFen);
    heatmapData.addAll(realStats);
  }

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
        body: jsonEncode({'fen': fenForEval, 'depth': 12, 'multipv': 3}),
      );

      if (response.statusCode == 200) {
        if (currentFen != fenForEval) return; // FEN mudou enquanto a API pensava

        final data = jsonDecode(response.body);

        List<dynamic> evalList = data is List ? data : [data];
        List<EngineEvaluation> newEvals = [];

        bool isFirstMove = true; 

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
              currentEvalScore = m < 0 ? -10.0 : 10.0; 
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

          isFirstMove = false; 

          List<String> cont = (item['continuationArr'] as List<dynamic>?)?.cast<String>() ?? [];
          String sanLine = _buildSanLine(fenForEval, cont);

          newEvals.add(EngineEvaluation(evalStr, sanLine, arrow));
        }

        if (newEvals.isNotEmpty) {
          topEvaluations = ObservableList.of(newEvals);
          engineArrows = ObservableList.of([newEvals.first.arrow]);
        }
      }
    } catch (e) {
      print('Erro ao consultar a Engine: $e');
    }
  }

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

    String pgn = tempBoard.pgn();
    pgn = pgn.replaceAll(RegExp(r'\[.*?\]\n*'), '').trim();
    return pgn;
  }
}