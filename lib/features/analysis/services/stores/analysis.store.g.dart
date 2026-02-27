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
  String toString() {
    return '''
currentMoveIndex: ${currentMoveIndex},
currentFen: ${currentFen},
fileName: ${fileName},
moveList: ${moveList},
showHeatmap: ${showHeatmap},
showEngine: ${showEngine},
heatmapData: ${heatmapData},
engineArrows: ${engineArrows}
    ''';
  }
}
