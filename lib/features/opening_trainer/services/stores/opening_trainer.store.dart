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

  // Guarda o repertório atual para podermos reiniciar o treinamento
  OpTrainRepertoire? currentRepertoire;

  @observable
  bool isAutoPlaying = false; // Trava para evitar conflito com o callback onMove

  @observable
  String currentMessage = "Selecione uma abertura ou carregue um arquivo para começar!";

  @observable
  bool isTrainingFinished = false;

  @observable
  String? errorMessage;

  @action
  void loadRepertoire(OpTrainRepertoire repertoire) {
    currentRepertoire = repertoire;
    chessController.loadFen(repertoire.initialFen);
    _currentNodeMoves = repertoire.expectedMoves;
    currentMessage = "Sua vez de jogar!";
    isTrainingFinished = false;
    errorMessage = null;
    isAutoPlaying = false;

    _checkAutoMove();
  }

  @action
  void restartTraining() {
    if (currentRepertoire != null) {
      loadRepertoire(currentRepertoire!);
    }
  }

  @action
  void onUserMove(String from, String to, [String? promotion]) {
    if (isTrainingFinished || _currentNodeMoves == null) return;
    if (isAutoPlaying) return; // Ignora o lance se for o computador jogando

    errorMessage = null;
    // Anexa a peça promovida à chave do lance se existir (ex: 'e7e8q')
    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";

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
      // Desfaz lance incorreto
      try {
        chessController.undoMove();
      } catch (_) {}
      errorMessage = "Lance incorreto! Tente se lembrar da preparação.";
    }
  }

  @action
  Future<void> _checkAutoMove() async {
    if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) return;

    // Pega todas as chaves cujos nós correspondentes são do tipo 'AUTO' (case-insensitive)
    final List<String> autoKeys = _currentNodeMoves!.entries
      .where((e) => e.value.type.toUpperCase() == 'AUTO')
      .map((e) => e.key)
      .toList();

    if (autoKeys.isNotEmpty) {
      isAutoPlaying = true;
      final savedRepertoire = currentRepertoire; // Salva o estado atual para evitar Race Condition

      await Future.delayed(const Duration(milliseconds: 600));

      // Se o usuário clicou em "Reiniciar" durante o delay, aborta a execução
      if (currentRepertoire != savedRepertoire) {
        isAutoPlaying = false;
        return; 
      }

      // Sorteia aleatoriamente UM dos lances AUTO
      final String randomMoveKey = autoKeys[Random().nextInt(autoKeys.length)];
      final OpTrainNode selectedNode = _currentNodeMoves![randomMoveKey]!;

      // Separa from, to e promoção dinamicamente
      final String from = randomMoveKey.substring(0, 2);
      final String to = randomMoveKey.substring(2, 4);
      final String? promotion = randomMoveKey.length > 4 ? randomMoveKey.substring(4, 5) : null;
      
      try {
        if (promotion != null) {
          try {
             chessController.makeMoveWithPromotion(from: from, to: to, pieceToPromoteTo: promotion);
          } catch (_) {
             // Fallback caso a versão da lib não suporte makeMoveWithPromotion
             chessController.makeMove(from: from, to: to);
          }
        } else {
          chessController.makeMove(from: from, to: to);
        }
      } catch (e) {
        // Se a engine recusar o lance AUTO, mostramos o erro na UI
        errorMessage = "Erro interno no lance automático ($from para $to): $e";
      }

      _updateMessage(selectedNode);
      _currentNodeMoves = selectedNode.expectedMoves;

      if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
        isTrainingFinished = true;
        currentMessage = "Treinamento concluído!";
      }

      // Delay seguro antes de liberar a UI para garantir que o onMove não cause conflito
      await Future.delayed(const Duration(milliseconds: 100));

      // Checa novamente caso tenha reiniciado exatamente no micro-delay final
      if (currentRepertoire != savedRepertoire) return; 

      isAutoPlaying = false;

      // Executa de novo caso a resposta do oponente force outra resposta automática
      _checkAutoMove();
    }
  }

  void _updateMessage(OpTrainNode node) {
    if (node.possibleMessages != null && node.possibleMessages!.isNotEmpty) {
      final int randomIndex = Random().nextInt(node.possibleMessages!.length);
      currentMessage = node.possibleMessages![randomIndex];
    }
  }
}