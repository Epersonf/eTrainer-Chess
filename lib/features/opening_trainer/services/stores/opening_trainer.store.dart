import 'dart:math';

import 'package:e_trainer_chess/features/opening_trainer/models/optrain_node.dart';
import 'package:e_trainer_chess/features/opening_trainer/models/optrain_repertoire.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

part 'opening_trainer.store.g.dart';

class OpeningTrainerStore = OpeningTrainerStoreBase with _$OpeningTrainerStore;

abstract class OpeningTrainerStoreBase with Store {
  final ChessBoardController chessController = ChessBoardController();
  Map<String, OpTrainNode>? _currentNodeMoves;

  @observable
  String currentMessage = "Carregue um arquivo .optrain para começar!";

  @observable
  bool isTrainingFinished = false;

  @observable
  String? errorMessage;

  @action
  void loadRepertoire(OpTrainRepertoire repertoire) {
    chessController.loadFen(repertoire.initialFen);
    _currentNodeMoves = repertoire.expectedMoves;
    currentMessage = "Sua vez de jogar!";
    isTrainingFinished = false;
    errorMessage = null;

    _checkAutoMove();
  }

  @action
  void onUserMove(String from, String to) {
    if (isTrainingFinished || _currentNodeMoves == null) return;
    errorMessage = null;

    final moveKey = "${from}${to}";

    if (_currentNodeMoves!.containsKey(moveKey)) {
      final nextNode = _currentNodeMoves![moveKey]!;

      _updateMessage(nextNode);
      _currentNodeMoves = nextNode.expectedMoves;

      if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
        isTrainingFinished = true;
        currentMessage = "Treinamento concluído! Você memorizou a linha.";
      } else {
        _checkAutoMove();
      }
    } else {
      // desfaz lance
      try {
        chessController.undoMove();
      } catch (_) {}
      errorMessage = "Lance incorreto! Tente se lembrar da preparação.";
    }
  }

  @action
  Future<void> _checkAutoMove() async {
    if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) return;

    final firstChildKey = _currentNodeMoves!.keys.first;
    final firstChildNode = _currentNodeMoves![firstChildKey]!;

    if (firstChildNode.type == 'AUTO') {
      await Future.delayed(const Duration(milliseconds: 600));

      final keys = _currentNodeMoves!.keys.toList();
      final randomMoveKey = keys[Random().nextInt(keys.length)];
      final selectedNode = _currentNodeMoves![randomMoveKey]!;

      final from = randomMoveKey.substring(0, 2);
      final to = randomMoveKey.substring(2, 4);
      try {
        chessController.makeMove(from: from, to: to);
      } catch (_) {}

      _updateMessage(selectedNode);
      _currentNodeMoves = selectedNode.expectedMoves;

      if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
        isTrainingFinished = true;
        currentMessage = "Treinamento concluído!";
      }
    }
  }

  void _updateMessage(OpTrainNode node) {
    if (node.possibleMessages != null && node.possibleMessages!.isNotEmpty) {
      final randomIndex = Random().nextInt(node.possibleMessages!.length);
      currentMessage = node.possibleMessages![randomIndex];
    }
  }
}
