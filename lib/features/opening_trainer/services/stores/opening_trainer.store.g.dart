// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_trainer.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OpeningTrainerStore on OpeningTrainerStoreBase, Store {
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

  late final _$OpeningTrainerStoreBaseActionController = ActionController(
    name: 'OpeningTrainerStoreBase',
    context: context,
  );

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
  void onUserMove(String from, String to) {
    final _$actionInfo = _$OpeningTrainerStoreBaseActionController.startAction(
      name: 'OpeningTrainerStoreBase.onUserMove',
    );
    try {
      return super.onUserMove(from, to);
    } finally {
      _$OpeningTrainerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentMessage: ${currentMessage},
isTrainingFinished: ${isTrainingFinished},
errorMessage: ${errorMessage}
    ''';
  }
}
