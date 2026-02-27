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
    game.load_pgn(pgn);
    currentFen = game.fen;
    _calculateHeatmap();
    if (showEngine) _requestEngineEval();
  }

  @action
  void nextMove() {
    currentFen = game.fen;
    _calculateHeatmap();
  }

  void _calculateHeatmap() {
    heatmapData.clear();
    heatmapData['e4'] = SquareStats(3, 1);
    heatmapData['d4'] = SquareStats(2, 2);
    heatmapData['f3'] = SquareStats(0, 2);
  }

  void _requestEngineEval() {
    Future.delayed(const Duration(milliseconds: 500), () {
      engineArrows = ObservableList.of([EngineArrow('e2', 'e4')]);
    });
  }
}
