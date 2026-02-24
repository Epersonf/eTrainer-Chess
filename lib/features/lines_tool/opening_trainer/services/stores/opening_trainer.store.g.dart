// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_trainer.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OpeningTrainerStore on OpeningTrainerStoreBase, Store {
  late final _$playerModeAtom = Atom(
    name: 'OpeningTrainerStoreBase.playerMode',
    context: context,
  );

  @override
  PlayerMode get playerMode {
    _$playerModeAtom.reportRead();
    return super.playerMode;
  }

  @override
  set playerMode(PlayerMode value) {
    _$playerModeAtom.reportWrite(value, super.playerMode, () {
      super.playerMode = value;
    });
  }

  late final _$variationModeAtom = Atom(
    name: 'OpeningTrainerStoreBase.variationMode',
    context: context,
  );

  @override
  VariationMode get variationMode {
    _$variationModeAtom.reportRead();
    return super.variationMode;
  }

  @override
  set variationMode(VariationMode value) {
    _$variationModeAtom.reportWrite(value, super.variationMode, () {
      super.variationMode = value;
    });
  }

  late final _$pendingVariationsAtom = Atom(
    name: 'OpeningTrainerStoreBase.pendingVariations',
    context: context,
  );

  @override
  Map<String, OpTrainNode>? get pendingVariations {
    _$pendingVariationsAtom.reportRead();
    return super.pendingVariations;
  }

  @override
  set pendingVariations(Map<String, OpTrainNode>? value) {
    _$pendingVariationsAtom.reportWrite(value, super.pendingVariations, () {
      super.pendingVariations = value;
    });
  }

  late final _$showCoordinatesAtom = Atom(
    name: 'OpeningTrainerStoreBase.showCoordinates',
    context: context,
  );

  @override
  bool get showCoordinates {
    _$showCoordinatesAtom.reportRead();
    return super.showCoordinates;
  }

  @override
  set showCoordinates(bool value) {
    _$showCoordinatesAtom.reportWrite(value, super.showCoordinates, () {
      super.showCoordinates = value;
    });
  }

  late final _$allowBadMovesAtom = Atom(
    name: 'OpeningTrainerStoreBase.allowBadMoves',
    context: context,
  );

  @override
  bool get allowBadMoves {
    _$allowBadMovesAtom.reportRead();
    return super.allowBadMoves;
  }

  @override
  set allowBadMoves(bool value) {
    _$allowBadMovesAtom.reportWrite(value, super.allowBadMoves, () {
      super.allowBadMoves = value;
    });
  }

  late final _$isAutoPlayingAtom = Atom(
    name: 'OpeningTrainerStoreBase.isAutoPlaying',
    context: context,
  );

  @override
  bool get isAutoPlaying {
    _$isAutoPlayingAtom.reportRead();
    return super.isAutoPlaying;
  }

  @override
  set isAutoPlaying(bool value) {
    _$isAutoPlayingAtom.reportWrite(value, super.isAutoPlaying, () {
      super.isAutoPlaying = value;
    });
  }

  late final _$hasMadeWrongMoveAtom = Atom(
    name: 'OpeningTrainerStoreBase.hasMadeWrongMove',
    context: context,
  );

  @override
  bool get hasMadeWrongMove {
    _$hasMadeWrongMoveAtom.reportRead();
    return super.hasMadeWrongMove;
  }

  @override
  set hasMadeWrongMove(bool value) {
    _$hasMadeWrongMoveAtom.reportWrite(value, super.hasMadeWrongMove, () {
      super.hasMadeWrongMove = value;
    });
  }

  late final _$currentMessageAtom = Atom(
    name: 'OpeningTrainerStoreBase.currentMessage',
    context: context,
  );

  @override
  String get currentMessage {
    _$currentMessageAtom.reportRead();
    return super.currentMessage;
  }

  @override
  set currentMessage(String value) {
    _$currentMessageAtom.reportWrite(value, super.currentMessage, () {
      super.currentMessage = value;
    });
  }

  late final _$isTrainingFinishedAtom = Atom(
    name: 'OpeningTrainerStoreBase.isTrainingFinished',
    context: context,
  );

  @override
  bool get isTrainingFinished {
    _$isTrainingFinishedAtom.reportRead();
    return super.isTrainingFinished;
  }

  @override
  set isTrainingFinished(bool value) {
    _$isTrainingFinishedAtom.reportWrite(value, super.isTrainingFinished, () {
      super.isTrainingFinished = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'OpeningTrainerStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$_checkAutoMoveAsyncAction = AsyncAction(
    'OpeningTrainerStoreBase._checkAutoMove',
    context: context,
  );

  @override
  Future<void> _checkAutoMove() {
    return _$_checkAutoMoveAsyncAction.run(() => super._checkAutoMove());
  }

  late final _$chooseVariationAsyncAction = AsyncAction(
    'OpeningTrainerStoreBase.chooseVariation',
    context: context,
  );

  @override
  Future<void> chooseVariation(String moveKey) {
    return _$chooseVariationAsyncAction.run(
      () => super.chooseVariation(moveKey),
    );
  }

  late final _$OpeningTrainerStoreBaseActionController = ActionController(
    name: 'OpeningTrainerStoreBase',
    context: context,
  );

  @override
  void toggleCoordinates() {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.toggleCoordinates',
    );
    try {
      return super.toggleCoordinates();
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAllowBadMoves(bool value) {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.setAllowBadMoves',
    );
    try {
      return super.setAllowBadMoves(value);
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPlayerMode(PlayerMode mode) {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.setPlayerMode',
    );
    try {
      return super.setPlayerMode(mode);
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVariationMode(VariationMode mode) {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.setVariationMode',
    );
    try {
      return super.setVariationMode(mode);
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void loadRepertoire(OpTrainRepertoire repertoire) {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.loadRepertoire',
    );
    try {
      return super.loadRepertoire(repertoire);
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void restartTraining() {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.restartTraining',
    );
    try {
      return super.restartTraining();
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onUserMove(String from, String to, [String? promotion]) {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.onUserMove',
    );
    try {
      return super.onUserMove(from, to, promotion);
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void undoWrongMove() {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.undoWrongMove',
    );
    try {
      return super.undoWrongMove();
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showHint() {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.showHint',
    );
    try {
      return super.showHint();
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
playerMode: ${playerMode},
variationMode: ${variationMode},
pendingVariations: ${pendingVariations},
showCoordinates: ${showCoordinates},
allowBadMoves: ${allowBadMoves},
isAutoPlaying: ${isAutoPlaying},
hasMadeWrongMove: ${hasMadeWrongMove},
currentMessage: ${currentMessage},
isTrainingFinished: ${isTrainingFinished},
errorMessage: ${errorMessage}
    ''';
  }
}
