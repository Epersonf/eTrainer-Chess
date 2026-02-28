// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AnalysisStore on AnalysisStoreBase, Store {
  late final _$currentMoveIndexAtom = Atom(
    name: 'AnalysisStoreBase.currentMoveIndex',
    context: context,
  );

  @override
  int get currentMoveIndex {
    _$currentMoveIndexAtom.reportRead();
    return super.currentMoveIndex;
  }

  @override
  set currentMoveIndex(int value) {
    _$currentMoveIndexAtom.reportWrite(value, super.currentMoveIndex, () {
      super.currentMoveIndex = value;
    });
  }

  late final _$currentFenAtom = Atom(
    name: 'AnalysisStoreBase.currentFen',
    context: context,
  );

  @override
  String get currentFen {
    _$currentFenAtom.reportRead();
    return super.currentFen;
  }

  @override
  set currentFen(String value) {
    _$currentFenAtom.reportWrite(value, super.currentFen, () {
      super.currentFen = value;
    });
  }

  late final _$fileNameAtom = Atom(
    name: 'AnalysisStoreBase.fileName',
    context: context,
  );

  @override
  String get fileName {
    _$fileNameAtom.reportRead();
    return super.fileName;
  }

  @override
  set fileName(String value) {
    _$fileNameAtom.reportWrite(value, super.fileName, () {
      super.fileName = value;
    });
  }

  late final _$moveListAtom = Atom(
    name: 'AnalysisStoreBase.moveList',
    context: context,
  );

  @override
  ObservableList<String> get moveList {
    _$moveListAtom.reportRead();
    return super.moveList;
  }

  @override
  set moveList(ObservableList<String> value) {
    _$moveListAtom.reportWrite(value, super.moveList, () {
      super.moveList = value;
    });
  }

  late final _$showHeatmapAtom = Atom(
    name: 'AnalysisStoreBase.showHeatmap',
    context: context,
  );

  @override
  bool get showHeatmap {
    _$showHeatmapAtom.reportRead();
    return super.showHeatmap;
  }

  @override
  set showHeatmap(bool value) {
    _$showHeatmapAtom.reportWrite(value, super.showHeatmap, () {
      super.showHeatmap = value;
    });
  }

  late final _$showEngineAtom = Atom(
    name: 'AnalysisStoreBase.showEngine',
    context: context,
  );

  @override
  bool get showEngine {
    _$showEngineAtom.reportRead();
    return super.showEngine;
  }

  @override
  set showEngine(bool value) {
    _$showEngineAtom.reportWrite(value, super.showEngine, () {
      super.showEngine = value;
    });
  }

  late final _$showWeakSquaresAtom = Atom(
    name: 'AnalysisStoreBase.showWeakSquares',
    context: context,
  );

  @override
  bool get showWeakSquares {
    _$showWeakSquaresAtom.reportRead();
    return super.showWeakSquares;
  }

  @override
  set showWeakSquares(bool value) {
    _$showWeakSquaresAtom.reportWrite(value, super.showWeakSquares, () {
      super.showWeakSquares = value;
    });
  }

  late final _$heatmapDataAtom = Atom(
    name: 'AnalysisStoreBase.heatmapData',
    context: context,
  );

  @override
  ObservableMap<String, SquareStats> get heatmapData {
    _$heatmapDataAtom.reportRead();
    return super.heatmapData;
  }

  @override
  set heatmapData(ObservableMap<String, SquareStats> value) {
    _$heatmapDataAtom.reportWrite(value, super.heatmapData, () {
      super.heatmapData = value;
    });
  }

  late final _$weakSquaresAtom = Atom(
    name: 'AnalysisStoreBase.weakSquares',
    context: context,
  );

  @override
  ObservableSet<String> get weakSquares {
    _$weakSquaresAtom.reportRead();
    return super.weakSquares;
  }

  @override
  set weakSquares(ObservableSet<String> value) {
    _$weakSquaresAtom.reportWrite(value, super.weakSquares, () {
      super.weakSquares = value;
    });
  }

  late final _$engineArrowsAtom = Atom(
    name: 'AnalysisStoreBase.engineArrows',
    context: context,
  );

  @override
  ObservableList<EngineArrow> get engineArrows {
    _$engineArrowsAtom.reportRead();
    return super.engineArrows;
  }

  @override
  set engineArrows(ObservableList<EngineArrow> value) {
    _$engineArrowsAtom.reportWrite(value, super.engineArrows, () {
      super.engineArrows = value;
    });
  }

  late final _$topEvaluationsAtom = Atom(
    name: 'AnalysisStoreBase.topEvaluations',
    context: context,
  );

  @override
  ObservableList<EngineEvaluation> get topEvaluations {
    _$topEvaluationsAtom.reportRead();
    return super.topEvaluations;
  }

  @override
  set topEvaluations(ObservableList<EngineEvaluation> value) {
    _$topEvaluationsAtom.reportWrite(value, super.topEvaluations, () {
      super.topEvaluations = value;
    });
  }

  late final _$currentEvalScoreAtom = Atom(
    name: 'AnalysisStoreBase.currentEvalScore',
    context: context,
  );

  @override
  double get currentEvalScore {
    _$currentEvalScoreAtom.reportRead();
    return super.currentEvalScore;
  }

  @override
  set currentEvalScore(double value) {
    _$currentEvalScoreAtom.reportWrite(value, super.currentEvalScore, () {
      super.currentEvalScore = value;
    });
  }

  late final _$currentEvalTextAtom = Atom(
    name: 'AnalysisStoreBase.currentEvalText',
    context: context,
  );

  @override
  String get currentEvalText {
    _$currentEvalTextAtom.reportRead();
    return super.currentEvalText;
  }

  @override
  set currentEvalText(String value) {
    _$currentEvalTextAtom.reportWrite(value, super.currentEvalText, () {
      super.currentEvalText = value;
    });
  }

  late final _$rootMovesAtom = Atom(
    name: 'AnalysisStoreBase.rootMoves',
    context: context,
  );

  @override
  ObservableMap<String, AnalysisNode> get rootMoves {
    _$rootMovesAtom.reportRead();
    return super.rootMoves;
  }

  @override
  set rootMoves(ObservableMap<String, AnalysisNode> value) {
    _$rootMovesAtom.reportWrite(value, super.rootMoves, () {
      super.rootMoves = value;
    });
  }

  late final _$currentPathAtom = Atom(
    name: 'AnalysisStoreBase.currentPath',
    context: context,
  );

  @override
  ObservableList<String> get currentPath {
    _$currentPathAtom.reportRead();
    return super.currentPath;
  }

  @override
  set currentPath(ObservableList<String> value) {
    _$currentPathAtom.reportWrite(value, super.currentPath, () {
      super.currentPath = value;
    });
  }

  late final _$startFenAtom = Atom(
    name: 'AnalysisStoreBase.startFen',
    context: context,
  );

  @override
  String get startFen {
    _$startFenAtom.reportRead();
    return super.startFen;
  }

  @override
  set startFen(String value) {
    _$startFenAtom.reportWrite(value, super.startFen, () {
      super.startFen = value;
    });
  }

  late final _$AnalysisStoreBaseActionController = ActionController(
    name: 'AnalysisStoreBase',
    context: context,
  );

  @override
  void toggleHeatmap() {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.toggleHeatmap',
    );
    try {
      return super.toggleHeatmap();
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleEngine() {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.toggleEngine',
    );
    try {
      return super.toggleEngine();
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleWeakSquares() {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.toggleWeakSquares',
    );
    try {
      return super.toggleWeakSquares();
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void loadPgn(String pgn, String name) {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.loadPgn',
    );
    try {
      return super.loadPgn(pgn, name);
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void prevMove() {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.prevMove',
    );
    try {
      return super.prevMove();
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void nextMove() {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.nextMove',
    );
    try {
      return super.nextMove();
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void jumpToMove(int index) {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.jumpToMove',
    );
    try {
      return super.jumpToMove(index);
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onMoveMade(String from, String to, [String? promotion]) {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.onMoveMade',
    );
    try {
      return super.onMoveMade(from, to, promotion);
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void jumpToNode(List<String> path) {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.jumpToNode',
    );
    try {
      return super.jumpToNode(path);
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void undoMove() {
    final _$actionInfo = _$AnalysisStoreBaseActionController.startAction(
      name: 'AnalysisStoreBase.undoMove',
    );
    try {
      return super.undoMove();
    } finally {
      _$AnalysisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentMoveIndex: ${currentMoveIndex},
currentFen: ${currentFen},
fileName: ${fileName},
moveList: ${moveList},
showHeatmap: ${showHeatmap},
showEngine: ${showEngine},
showWeakSquares: ${showWeakSquares},
heatmapData: ${heatmapData},
weakSquares: ${weakSquares},
engineArrows: ${engineArrows},
topEvaluations: ${topEvaluations},
currentEvalScore: ${currentEvalScore},
currentEvalText: ${currentEvalText},
rootMoves: ${rootMoves},
currentPath: ${currentPath},
startFen: ${startFen}
    ''';
  }
}
