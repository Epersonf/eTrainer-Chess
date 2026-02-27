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

  // Histórico de FENs para navegação
  List<String> _fensHistory = [chess_lib.Chess.DEFAULT_POSITION];
  int _currentMoveIndex = 0;

  @observable
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;

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
  void loadPgn(String pgn) {
    // Carrega o jogo para validar e pegar a história
    game.load_pgn(pgn);
    final historyMoves = game.history;

    // Refaz os lances em um tabuleiro temporário para salvar todos os FENs na lista
    final tempGame = chess_lib.Chess();
    _fensHistory = [tempGame.fen];
    for (var move in historyMoves) {
      tempGame.move(move);
      _fensHistory.add(tempGame.fen);
    }

    // Vai para o primeiro lance do PGN
    _currentMoveIndex = 0;
    _applyCurrentState();
  }

  @action
  void prevMove() {
    if (_currentMoveIndex > 0) {
      _currentMoveIndex--;
      _applyCurrentState();
    }
  }

  @action
  void nextMove() {
    if (_currentMoveIndex < _fensHistory.length - 1) {
      _currentMoveIndex++;
      _applyCurrentState();
    }
  }

  void _applyCurrentState() {
    currentFen = _fensHistory[_currentMoveIndex];
    game.load(currentFen); // Atualiza o motor interno
    _calculateHeatmap();
    if (showEngine) _requestEngineEval();
  }

  void _calculateHeatmap() {
    heatmapData.clear();
    // Por enquanto, valores simulados para teste visual
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
