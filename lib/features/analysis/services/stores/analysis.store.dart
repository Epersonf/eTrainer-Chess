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
  ObservableMap<String, SquareStats> heatmapData = ObservableMap<String, SquareStats>();

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
    // 1. Limpa quebras de linha que quebram o parser
    final cleanPgn = pgn.replaceAll('\r\n', '\n').trim();
    final tempGame = chess_lib.Chess();

    // 2. Tenta fazer o parse. Se falhar, avisa na UI.
    if (!tempGame.load_pgn(cleanPgn)) {
      fileName = "Erro: Arquivo PGN inválido";
      moveList.clear();
      return;
    }

    fileName = name;
    moveList.clear();
    engineArrows.clear();

    // 3. Salva a lista de lances em SAN (e4, Nf3, etc)
    final moves = tempGame.history;
    for (var m in moves) {
      moveList.add(m.toString());
    }

    // 4. Refaz o jogo gerando a lista de FENs (O Segredo!)
    final replayGame = chess_lib.Chess();
    final List<String> fens = [replayGame.fen]; // Fen inicial

    for (var move in moveList) {
      replayGame.move(move); // Move pelo SAN
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
