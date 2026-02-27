import 'package:mobx/mobx.dart';
import 'package:chess/chess.dart' as chess_lib;

part 'analysis.store.g.dart';

class AnalysisStore = AnalysisStoreBase with _$AnalysisStore;

class SquareStats {
  final int attacks;
  final int defenses;
  SquareStats(this.attacks, this.defenses);
}

class EngineArrow {
  final String from;
  final String to;
  EngineArrow(this.from, this.to);
}

abstract class AnalysisStoreBase with Store {
  final chess_lib.Chess game = chess_lib.Chess();
  List<String> _fensHistory = [chess_lib.Chess.DEFAULT_POSITION];

  @observable
  int currentMoveIndex = 0; // Transformado em observable

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
  ObservableMap<String, SquareStats> heatmapData =
      ObservableMap<String, SquareStats>();

  @observable
  ObservableList<EngineArrow> engineArrows = ObservableList<EngineArrow>();

  @action
  void toggleHeatmap() => showHeatmap = !showHeatmap;

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
    // Limpa quebras de linha que quebram o parser do Windows
    final cleanPgn = pgn.replaceAll('\r\n', '\n').trim();
    final tempGame = chess_lib.Chess();

    // Tenta fazer o parse do PGN
    if (!tempGame.load_pgn(cleanPgn)) {
      fileName = "Erro: Arquivo PGN inválido";
      moveList.clear();
      return;
    }

    fileName = name;
    engineArrows.clear();

    // -----------------------------------------------------------------
    // SOLUÇÃO: Pegar o texto limpo do PGN e extrair apenas os lances!
    // -----------------------------------------------------------------
    String fullPgnText = tempGame.pgn();

    // 1. Remove Headers (ex: [Event "xyz"])
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\[.*?\]'), '');
    // 2. Remove Comentários (ex: { excelente lance })
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\{.*?\}'), '');
    // 3. Remove Variações (ex: ( 1... d5 ) )
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\(.*?\)'), '');
    // 4. Remove a numeração das jogadas (ex: "1.", "25.")
    fullPgnText = fullPgnText.replaceAll(RegExp(r'\d+\.'), '');
    // 5. Remove resultados padrão do final do arquivo
    fullPgnText = fullPgnText
        .replaceAll('1-0', '')
        .replaceAll('0-1', '')
        .replaceAll('1/2-1/2', '')
        .replaceAll('*', '');

    // Agora temos só o texto puro dos lances, vamos separar os espaços num Array:
    final extractedMoves = fullPgnText
        .trim()
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty) // Garante que não pegue vazios
        .toList();

    // Atualiza a UI (Agora sim, vai aparecer 'e4', 'Nf3', etc)
    moveList.clear();
    moveList.addAll(extractedMoves);

    // -----------------------------------------------------------------
    // Refaz o jogo gerando a lista de posições FENs corretamente
    // -----------------------------------------------------------------
    final replayGame = chess_lib.Chess();
    final List<String> fens = [replayGame.fen]; // Fen inicial

    for (var moveStr in extractedMoves) {
      replayGame.move(moveStr); // Engine entende perfeitamente a string SAN
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
    game.load(currentFen); // Sincroniza o motor da biblioteca
    _calculateHeatmap();
    if (showEngine) _requestEngineEval();
  }

  void _calculateHeatmap() {
    heatmapData.clear();
    heatmapData['e4'] = SquareStats(3, 1);
    heatmapData['d4'] = SquareStats(2, 2);
    heatmapData['f3'] = SquareStats(0, 2);
  }

  void _requestEngineEval() {
    engineArrows.clear();
    Future.delayed(const Duration(milliseconds: 500), () {
      engineArrows = ObservableList.of([EngineArrow('e2', 'e4')]);
    });
  }
}
