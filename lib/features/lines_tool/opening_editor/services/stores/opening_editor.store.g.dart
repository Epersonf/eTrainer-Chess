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

  late final _$currentMessagesAtom = Atom(
    name: 'OpeningEditorStoreBase.currentMessages',
    context: context,
  );

  @override
  ObservableList<String> get currentMessages {
    _$currentMessagesAtom.reportRead();
    return super.currentMessages;
  }

  @override
  set currentMessages(ObservableList<String> value) {
    _$currentMessagesAtom.reportWrite(value, super.currentMessages, () {
      super.currentMessages = value;
    });
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
  void advanceMove() {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.advanceMove',
    );
    try {
      return super.advanceMove();
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteNode(List<String> pathToDelete) {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.deleteNode',
    );
    try {
      return super.deleteNode(pathToDelete);
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addMessage() {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.addMessage',
    );
    try {
      return super.addMessage();
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateMessage(int index, String text) {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.updateMessage',
    );
    try {
      return super.updateMessage(index, text);
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeMessage(int index) {
    final _$actionInfo = _$OpeningEditorStoreBaseActionController.startAction(
      name: 'OpeningEditorStoreBase.removeMessage',
    );
    try {
      return super.removeMessage(index);
    } finally {
      _$OpeningEditorStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
repertoire: ${repertoire},
currentPath: ${currentPath},
currentMessages: ${currentMessages}
    ''';
  }
}
