import 'dart:math';

import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

part 'opening_trainer.store.g.dart';

class OpeningTrainerStore = OpeningTrainerStoreBase with _$OpeningTrainerStore;

enum PlayerMode { white, black, both }

enum VariationMode { random, select }

abstract class OpeningTrainerStoreBase with Store {
  final ChessBoardController chessController = ChessBoardController();
  Map<String, OpTrainNode>? _currentNodeMoves;

  OpTrainRepertoire? currentRepertoire;

  // NOVO: Controle de Modos
  @observable
  PlayerMode playerMode = PlayerMode.white;

  @observable
  VariationMode variationMode = VariationMode.random;

  @observable
  Map<String, OpTrainNode>? pendingVariations;

  // NOVO: Salva o FEN válido mais recente para consertar o Undo perfeitamente
  String _lastValidFen = '';

  @observable
  bool showCoordinates = true;

  @observable
  bool isAutoPlaying = false;

  @observable
  bool hasMadeWrongMove = false;

  @observable
  String currentMessage = "Selecione uma abertura ou carregue um arquivo para começar!";

  @observable
  bool isTrainingFinished = false;

  @observable
  String? errorMessage;

  @action
  void toggleCoordinates() {
    showCoordinates = !showCoordinates;
  }

  // NOVO: Ação para mudar a cor e reiniciar automaticamente o treino
  @action
  void setPlayerMode(PlayerMode mode) {
    playerMode = mode;
    restartTraining();
  }

  @action
  void setVariationMode(VariationMode mode) {
    variationMode = mode;
    restartTraining();
  }

  @action
  void loadRepertoire(OpTrainRepertoire repertoire) {
    currentRepertoire = repertoire;
    chessController.loadFen(repertoire.initialFen);
    _lastValidFen = repertoire.initialFen; // Salva o FEN inicial
    
    _currentNodeMoves = repertoire.expectedMoves;
    currentMessage = "Treinamento iniciado. Faça seu lance!";
    isTrainingFinished = false;
    errorMessage = null;
    isAutoPlaying = false;
    hasMadeWrongMove = false;
    showCoordinates = true;

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
    if (isAutoPlaying || hasMadeWrongMove) return;

    errorMessage = null;
    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";

    if (_currentNodeMoves!.containsKey(moveKey)) {
      final nextNode = _currentNodeMoves![moveKey]!;

      // ACERTOU: Atualiza o estado válido
      _lastValidFen = chessController.getFen(); 

      _updateMessage(nextNode);
      _currentNodeMoves = nextNode.expectedMoves;

      if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
        isTrainingFinished = true;
        currentMessage = "Treinamento concluído! Você memorizou a linha.";
      } else {
        _checkAutoMove();
      }
    } else {
      // ERROU: Trava o jogo, mas mantém a peça visualmente onde o usuário soltou
      hasMadeWrongMove = true;
      errorMessage = "Lance incorreto! Tente se lembrar da preparação.";
    }
  }

  @action
  void undoWrongMove() {
    // CONSERTO DO UNDO: Restaura o FEN gravado no último lance válido
    chessController.loadFen(_lastValidFen);
    hasMadeWrongMove = false;
    errorMessage = null;
    currentMessage = "Tente novamente.";
  }

  @action
  void showHint() {
    if (isTrainingFinished || _currentNodeMoves == null || _currentNodeMoves!.isEmpty) return;

    final validMoves = _currentNodeMoves!.keys.toList();
    if (validMoves.isNotEmpty) {
      final movesStr = validMoves.map((m) {
        if (m.length == 4) return "${m.substring(0, 2)}-${m.substring(2, 4)}";
        if (m.length == 5) return "${m.substring(0, 2)}-${m.substring(2, 4)}=${m[4].toUpperCase()}";
        return m;
      }).join(" ou ");

      currentMessage = "💡 Dica: Jogue $movesStr";
    }
  }

  @action
  Future<void> _checkAutoMove() async {
    if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) return;

    // Lógica inteligente de turno: lê quem joga direto do FEN
    final isWhiteTurn = chessController.getFen().contains(' w ');
    
    // Verifica se a engine deve jogar
    final shouldAutoMove = (playerMode == PlayerMode.white && !isWhiteTurn) ||
                           (playerMode == PlayerMode.black && isWhiteTurn);

    if (shouldAutoMove) {
      isAutoPlaying = true;
      final savedRepertoire = currentRepertoire;

      await Future.delayed(const Duration(milliseconds: 600));

      if (currentRepertoire != savedRepertoire) {
        isAutoPlaying = false;
        return;
      }

      // NOVO: Seleciona randomicamente qualquer lance esperado ou pede escolha
      final availableMoves = _currentNodeMoves!.keys.toList();

      // Se houver mais de uma opção e o modo for Select, pause e exponha as opções para a UI
      if (availableMoves.length > 1 && variationMode == VariationMode.select) {
        pendingVariations = _currentNodeMoves;
        isAutoPlaying = false;
        return;
      }

      // Se for random ou só tiver 1 lance, sorteia (ou pega o único) e joga
      final randomMoveKey = availableMoves[Random().nextInt(availableMoves.length)];
      await _executeEngineMove(randomMoveKey);
    }
  }

  @action
  Future<void> chooseVariation(String moveKey) async {
    pendingVariations = null;
    isAutoPlaying = true;
    await _executeEngineMove(moveKey);
  }

  Future<void> _executeEngineMove(String moveKey) async {
    final selectedNode = _currentNodeMoves![moveKey]!;

    final String from = moveKey.substring(0, 2);
    final String to = moveKey.substring(2, 4);
    final String? promotion = moveKey.length > 4 ? moveKey.substring(4, 5) : null;

    try {
      if (promotion != null) {
        try {
          chessController.makeMoveWithPromotion(from: from, to: to, pieceToPromoteTo: promotion);
        } catch (_) {
          chessController.makeMove(from: from, to: to);
        }
      } else {
        chessController.makeMove(from: from, to: to);
      }
    } catch (e) {
      errorMessage = "Erro interno no lance automático ($from para $to): $e";
    }

    _lastValidFen = chessController.getFen();
    _updateMessage(selectedNode);
    _currentNodeMoves = selectedNode.expectedMoves;

    if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
      isTrainingFinished = true;
      currentMessage = "Treinamento concluído!";
    }

    await Future.delayed(const Duration(milliseconds: 100));
    isAutoPlaying = false;

    _checkAutoMove();
  }

  void _updateMessage(OpTrainNode node) {
    if (node.possibleMessages != null && node.possibleMessages!.isNotEmpty) {
      final int randomIndex = Random().nextInt(node.possibleMessages!.length);
      currentMessage = node.possibleMessages![randomIndex];
    }
  }

  void dispose() {
    chessController.dispose();
  }
}