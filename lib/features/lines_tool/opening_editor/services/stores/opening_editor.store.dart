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

  @observable
  String? currentVariantName;

  // Helper para clonar a árvore nativamente sem usar json dinâmico
  Map<String, OpTrainNode> _cloneTree(Map<String, OpTrainNode>? original) {
    if (original == null) return {};
    return original.map((k, v) => MapEntry(k, OpTrainNode(
      name: v.name,
      possibleMessages: v.possibleMessages?.toList(),
      expectedMoves: _cloneTree(v.expectedMoves),
    )));
  }

  @action
  void onMoveMade(String from, String to, [String? promotion]) {
    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";
    
    // Clona a árvore com tipos estritos para o MobX não reclamar
    final newRoot = _cloneTree(repertoire.expectedMoves);
    Map<String, OpTrainNode> currentMap = newRoot;
    
    for (String pathKey in currentPath) {
      if (!currentMap.containsKey(pathKey)) {
         currentMap[pathKey] = OpTrainNode(name: null, possibleMessages: [], expectedMoves: {});
      }
      if (currentMap[pathKey]!.expectedMoves == null) {
        currentMap[pathKey] = OpTrainNode(
          name: currentMap[pathKey]!.name,
          possibleMessages: currentMap[pathKey]!.possibleMessages,
          expectedMoves: {},
        );
      }
      currentMap = currentMap[pathKey]!.expectedMoves!;
    }

    if (!currentMap.containsKey(moveKey)) {
      currentMap[moveKey] = OpTrainNode(
        name: null,
        possibleMessages: [],
        expectedMoves: {},
      );
    }

    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: newRoot,
    );

    // CORREÇÃO: Criar uma nova instância dispara a notificação global do MobX
    currentPath = ObservableList.of([...currentPath, moveKey]);
    _loadMessagesForCurrentNode();
  }

  @action
  void undoMove() {
    if (currentPath.isNotEmpty) {
      final newPath = List<String>.from(currentPath)..removeLast();
      jumpToNode(newPath);
    }
  }

  @action
  void jumpToNode(List<String> path) {
    // CORREÇÃO: Sobrescrever a variável faz o átomo acordar todos os Observers pendentes
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

    final newRoot = _cloneTree(repertoire.expectedMoves);
    Map<String, OpTrainNode> currentMap = newRoot;

    // Navega até o pai do nó que será deletado
    for (int i = 0; i < pathToDelete.length - 1; i++) {
      currentMap = currentMap[pathToDelete[i]]!.expectedMoves!;
    }

    // Remove o nó
    final keyToRemove = pathToDelete.last;
    currentMap.remove(keyToRemove);
    
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: newRoot,
    );

    // Se o usuário deletou a variante atual, volte o tabuleiro
    final pathStr = pathToDelete.join(',');
    final currentStr = currentPath.join(',');
    if (currentStr.startsWith(pathStr)) {
      final newPath = pathToDelete.sublist(0, pathToDelete.length - 1);
      jumpToNode(newPath);
    }
  }

  @action
  void renameNodeByPath(List<String> path, String newName) {
    if (path.isEmpty) return;

    final newRoot = _cloneTree(repertoire.expectedMoves);
    Map<String, OpTrainNode> currentMap = newRoot;

    // Navega até o pai do nó que será renomeado
    for (int i = 0; i < path.length - 1; i++) {
      currentMap = currentMap[path[i]]!.expectedMoves!;
    }

    final targetKey = path.last;
    final existingNode = currentMap[targetKey]!;

    // Atualiza o nó com o novo nome
    currentMap[targetKey] = OpTrainNode(
      name: newName.trim().isEmpty ? null : newName.trim(),
      possibleMessages: existingNode.possibleMessages,
      expectedMoves: existingNode.expectedMoves,
    );
    
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: newRoot,
    );

    // Se o nó renomeado for o que está focado no momento, sincroniza o textfield
    if (currentPath.join(',') == path.join(',')) {
      currentVariantName = currentMap[targetKey]!.name;
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
    
    final newRoot = _cloneTree(repertoire.expectedMoves);
    Map<String, OpTrainNode> currentMap = newRoot;
    
    for (int i = 0; i < currentPath.length - 1; i++) {
      currentMap = currentMap[currentPath[i]]!.expectedMoves!;
    }
    
    final lastKey = currentPath.last;
    final existingNode = currentMap[lastKey]!;
    
    currentMap[lastKey] = OpTrainNode(
      name: currentVariantName?.trim().isEmpty == true ? null : currentVariantName,
      possibleMessages: currentMessages.where((msg) => msg.trim().isNotEmpty).toList(),
      expectedMoves: existingNode.expectedMoves,
    );
    
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: newRoot,
    );
  }

  void _loadMessagesForCurrentNode() {
    if (currentPath.isEmpty) {
      currentMessages.clear();
      currentVariantName = null;
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

    currentVariantName = node?.name;
  }

  @action
  void updateVariantName(String name) {
    currentVariantName = name;
    _syncMessagesToRepertoire();
  }

  String exportJson() {
    final Map<String, dynamic> json = repertoire.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  void dispose() {
    chessController.dispose();
  }
}