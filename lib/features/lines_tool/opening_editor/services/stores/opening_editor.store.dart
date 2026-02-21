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
  String currentMessagesInput = '';

  @action
  void onMoveMade(String from, String to, [String? promotion]) {
    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";
    Map<String, OpTrainNode> currentMap = repertoire.expectedMoves;
    for (String pathKey in currentPath) {
      currentMap = currentMap[pathKey]!.expectedMoves ?? {};
    }

    if (!currentMap.containsKey(moveKey)) {
      currentMap[moveKey] = OpTrainNode(
        possibleMessages: [],
        expectedMoves: {},
      );
      repertoire = OpTrainRepertoire(
        initialFen: repertoire.initialFen,
        expectedMoves: Map.from(repertoire.expectedMoves),
      );
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
  void saveMessages(String text) {
    if (currentPath.isEmpty) return;

    List<String> msgs = text.split('\n').where((s) => s.trim().isNotEmpty).toList();

    Map<String, OpTrainNode> currentMap = repertoire.expectedMoves;
    for (int i = 0; i < currentPath.length - 1; i++) {
      currentMap = currentMap[currentPath[i]]!.expectedMoves!;
    }

    final lastKey = currentPath.last;
    final existingNode = currentMap[lastKey]!;
    currentMap[lastKey] = OpTrainNode(
      possibleMessages: msgs,
      expectedMoves: existingNode.expectedMoves,
    );

    repertoire = OpTrainRepertoire(
      initialFen: repertoire.initialFen,
      expectedMoves: Map.from(repertoire.expectedMoves),
    );
  }

  void _loadMessagesForCurrentNode() {
    if (currentPath.isEmpty) {
      currentMessagesInput = '';
      return;
    }

    Map<String, OpTrainNode> currentMap = repertoire.expectedMoves;
    OpTrainNode? node;
    for (String pathKey in currentPath) {
      node = currentMap[pathKey];
      currentMap = node?.expectedMoves ?? {};
    }

    currentMessagesInput = node?.possibleMessages?.join('\n') ?? '';
  }

  String exportJson() {
    final Map<String, dynamic> json = repertoire.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  void dispose() {
    chessController.dispose();
  }
}
