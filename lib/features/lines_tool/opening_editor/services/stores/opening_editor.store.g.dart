// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_editor.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OpeningEditorStore on OpeningEditorStoreBase, Store {
  late final _$repertoireAtom = Atom(
    name: 'OpeningEditorStoreBase.repertoire',
    context: context,
  );

  @override
  OpTrainRepertoire get repertoire {
    _$repertoireAtom.reportRead();
    return super.repertoire;
  }

  @override
  set repertoire(OpTrainRepertoire value) {
    _$repertoireAtom.reportWrite(value, super.repertoire, () {
      super.repertoire = value;
    });
  }

  late final _$currentPathAtom = Atom(
    name: 'OpeningEditorStoreBase.currentPath',
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

  late final _$currentMessagesInputAtom = Atom(
    name: 'OpeningEditorStoreBase.currentMessagesInput',
    context: context,
  );

  @override
  String get currentMessagesInput {
    _$currentMessagesInputAtom.reportRead();
    return super.currentMessagesInput;
  }

  @override
  set currentMessagesInput(String value) {
    _$currentMessagesInputAtom.reportWrite(
      value,
      super.currentMessagesInput,
      () {
        super.currentMessagesInput = value;
      },
    );
  }

  late final _$OpeningEditorStoreBaseActionController = ActionController(
    name: 'OpeningEditorStoreBase',
    context: context,
  );

  @override
  void onMoveMade(String from, String to, [String? promotion]) {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.onMoveMade',
    );
    try {
      return super.onMoveMade(from, to, promotion);
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void undoMove() {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.undoMove',
    );
    try {
      return super.undoMove();
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void jumpToNode(List<String> path) {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.jumpToNode',
    );
    try {
      return super.jumpToNode(path);
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void saveMessages(String text) {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.saveMessages',
    );
    try {
      return super.saveMessages(text);
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
repertoire: ${repertoire},
currentPath: ${currentPath},
currentMessagesInput: ${currentMessagesInput}
    ''';
  }
}
