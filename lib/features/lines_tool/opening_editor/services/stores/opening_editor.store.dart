import 'dart:convert';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

part 'opening_editor.store.g.dart';

class OpeningEditorStore = OpeningEditorStoreBase with _$OpeningEditorStore;

abstract class OpeningEditorStoreBase with Store {
  final ChessBoardController chessController = ChessBoardController();

  @observable
  OpTrainRepertoire repertoire = OpTrainRepertoire(
    initialFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    expectedMoves: {},
  );

  @observable
  ObservableList<String> currentPath = ObservableList<String>();

  @observable
  ObservableList<String> currentMessages = ObservableList<String>();

  @action
  void onMoveMade(String from, String to, [String? promotion]) {
    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";
    
    // Usamos toJson/fromJson para criar uma cópia mutável profunda do repertório facilmente
    final map = repertoire.toJson();
    Map<String, dynamic> currentMap = map['expectedMoves'];
    
    for (String pathKey in currentPath) {
      if (currentMap[pathKey]['expectedMoves'] == null) {
        currentMap[pathKey]['expectedMoves'] = <String, dynamic>{};
      }
      currentMap = currentMap[pathKey]['expectedMoves'];
    }

    if (!currentMap.containsKey(moveKey)) {
      currentMap[moveKey] = {
        'possibleMessages': <String>[],
        'expectedMoves': <String, dynamic>{},
      };
      repertoire = OpTrainRepertoire.fromJson(map);
    }

    currentPath.add(moveKey);
    _loadMessagesForCurrentNode();
  }

  @action
  void undoMove() {
    if (currentPath.isNotEmpty) {
      currentPath.removeLast();
      chessController.undoMove();
      _loadMessagesForCurrentNode();
    }
  }

  @action
  void jumpToNode(List<String> path) {
    currentPath = ObservableList.of(path);
    chessController.resetBoard();
    for (String move in path) {
      final from = move.substring(0, 2);
      final to = move.substring(2, 4);
      final promotion = move.length > 4 ? move.substring(4, 5) : null;

      if (promotion != null) {
        chessController.makeMoveWithPromotion(from: from, to: to, pieceToPromoteTo: promotion);
      } else {
        chessController.makeMove(from: from, to: to);
      }
    }
    _loadMessagesForCurrentNode();
  }

  @action
  void advanceMove() {
    Map<String, OpTrainNode> currentMap = repertoire.expectedMoves;
    for (String pathKey in currentPath) {
      currentMap = currentMap[pathKey]?.expectedMoves ?? {};
    }

    if (currentMap.isNotEmpty) {
      final firstMove = currentMap.keys.first;
      final newPath = List<String>.from(currentPath)..add(firstMove);
      jumpToNode(newPath);
    }
  }

  @action
  void deleteNode(List<String> pathToDelete) {
    if (pathToDelete.isEmpty) return;

    final map = repertoire.toJson();
    Map<String, dynamic> currentMap = map['expectedMoves'];

    // Navega até o pai do nó que será deletado
    for (int i = 0; i < pathToDelete.length - 1; i++) {
      currentMap = currentMap[pathToDelete[i]]['expectedMoves'];
    }

    // Remove o nó
    final keyToRemove = pathToDelete.last;
    currentMap.remove(keyToRemove);
    
    repertoire = OpTrainRepertoire.fromJson(map);

    // Se o usuário deletou a variante atual, volte o tabuleiro
    final pathStr = pathToDelete.join(',');
    final currentStr = currentPath.join(',');
    if (currentStr.startsWith(pathStr)) {
      final newPath = pathToDelete.sublist(0, pathToDelete.length - 1);
      jumpToNode(newPath);
    }
  }

  // ---- MANIPULAÇÃO DE MENSAGENS ----

  @action
  void addMessage() {
    currentMessages.add("");
    _syncMessagesToRepertoire();
  }

  @action
  void updateMessage(int index, String text) {
    currentMessages[index] = text;
    _syncMessagesToRepertoire();
  }

  @action
  void removeMessage(int index) {
    currentMessages.removeAt(index);
    _syncMessagesToRepertoire();
  }

  void _syncMessagesToRepertoire() {
    if (currentPath.isEmpty) return;
    
    final map = repertoire.toJson();
    Map<String, dynamic> currentMap = map['expectedMoves'];
    
    for (int i = 0; i < currentPath.length - 1; i++) {
      currentMap = currentMap[currentPath[i]]['expectedMoves'];
    }
    
    final lastKey = currentPath.last;
    currentMap[lastKey]['possibleMessages'] = currentMessages.where((msg) => msg.trim().isNotEmpty).toList();
    
    repertoire = OpTrainRepertoire.fromJson(map);
  }

  void _loadMessagesForCurrentNode() {
    if (currentPath.isEmpty) {
      currentMessages.clear();
      return;
    }

    Map<String, OpTrainNode> currentMap = repertoire.expectedMoves;
    OpTrainNode? node;
    for (String pathKey in currentPath) {
      node = currentMap[pathKey];
      currentMap = node?.expectedMoves ?? {};
    }

    currentMessages.clear();
    if (node?.possibleMessages != null) {
      currentMessages.addAll(node!.possibleMessages!);
    }
  }

  String exportJson() {
    final Map<String, dynamic> json = repertoire.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  void dispose() {
    chessController.dispose();
  }
}
