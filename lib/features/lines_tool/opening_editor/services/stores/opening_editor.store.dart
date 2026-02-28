import 'dart:convert';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:mobx/mobx.dart';
import 'package:chess/chess.dart' as chess_lib;

part 'opening_editor.store.g.dart';

class OpeningEditorStore = OpeningEditorStoreBase with _$OpeningEditorStore;

abstract class OpeningEditorStoreBase with Store {
  final chess_lib.Chess game = chess_lib.Chess();

  @observable
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;

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

  // Atualização Imutável Otimizada (Structural Sharing)
  Map<String, OpTrainNode> _updateTree(
    Map<String, OpTrainNode>? currentNodes,
    List<String> path,
    int depth,
    OpTrainNode? Function(OpTrainNode?) updater,
  ) {
    final nodes = Map<String, OpTrainNode>.from(currentNodes ?? {});
    
    if (depth == path.length - 1) {
      final targetKey = path[depth];
      final updatedNode = updater(nodes[targetKey]);
      if (updatedNode == null) {
        nodes.remove(targetKey); // Se retornar nulo, deleta o nó
      } else {
        nodes[targetKey] = updatedNode;
      }
      return nodes;
    }

    final currentKey = path[depth];
    final nextNode = nodes[currentKey] ?? OpTrainNode(expectedMoves: {});
    
    nodes[currentKey] = OpTrainNode(
      name: nextNode.name,
      possibleMessages: nextNode.possibleMessages,
      quality: nextNode.quality,
      expectedMoves: _updateTree(nextNode.expectedMoves, path, depth + 1, updater),
    );

    return nodes;
  }

  @action
  void onMoveMade(String from, String to, [String? promotion]) {
    // Primeiro, valida e aplica o lance na engine interna
    final moveResult = game.move({"from": from, "to": to, "promotion": promotion ?? 'q'});
    if (moveResult == false) return; // Lance inválido, aborta

    currentFen = game.fen;

    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";

    final newPath = [...currentPath, moveKey];
    
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: _updateTree(repertoire.expectedMoves, newPath, 0, (node) {
        return node ?? OpTrainNode(
          name: null,
          possibleMessages: [],
          expectedMoves: {},
          quality: MoveQuality.good,
        );
      }),
    );

    // Atualiza o caminho e mensagens
    currentPath = ObservableList.of(newPath);
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

    game.load(repertoire.initialFen);
    for (String move in path) {
      if (move.length < 4) continue;
      final from = move.substring(0, 2);
      final to = move.substring(2, 4);
      final promotion = move.length > 4 ? move.substring(4, 5) : null;

      game.move({"from": from, "to": to, "promotion": promotion ?? 'q'});
    }

    currentFen = game.fen;

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
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: _updateTree(repertoire.expectedMoves, pathToDelete, 0, (node) => null), // <-- Mágica aqui
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
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: _updateTree(repertoire.expectedMoves, path, 0, (node) {
        if (node == null) return null;
        return OpTrainNode(
          name: newName.trim().isEmpty ? null : newName.trim(),
          possibleMessages: node.possibleMessages,
          expectedMoves: node.expectedMoves,
          quality: node.quality,
        );
      }),
    );

    if (currentPath.join(',') == path.join(',')) {
      currentVariantName = newName.trim().isEmpty ? null : newName.trim();
    }
  }

  @action
  void toggleNodeQuality(List<String> path) {
    if (path.isEmpty) return;
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: _updateTree(repertoire.expectedMoves, path, 0, (node) {
        if (node == null) return null;
        return OpTrainNode(
          name: node.name,
          possibleMessages: node.possibleMessages,
          expectedMoves: node.expectedMoves,
          quality: node.quality == MoveQuality.good ? MoveQuality.bad : MoveQuality.good,
        );
      }),
    );
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
    
    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: _updateTree(repertoire.expectedMoves, currentPath, 0, (node) {
        if (node == null) return null;
        return OpTrainNode(
          name: currentVariantName?.trim().isEmpty == true ? null : currentVariantName,
          possibleMessages: currentMessages.where((msg) => msg.trim().isNotEmpty).toList(),
          expectedMoves: node.expectedMoves,
          quality: node.quality,
        );
      }),
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

  @action
  void loadRepertoire(OpTrainRepertoire newRepertoire) {
    repertoire = newRepertoire;
    currentPath.clear();
    currentMessages.clear();
    currentVariantName = null;
    
    game.load(repertoire.initialFen);
    currentFen = game.fen;
  }

  String exportJson() {
    final Map<String, dynamic> json = repertoire.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  void dispose() {
    // Nada a fazer: chess_lib.Chess não precisa de dispose
  }
}