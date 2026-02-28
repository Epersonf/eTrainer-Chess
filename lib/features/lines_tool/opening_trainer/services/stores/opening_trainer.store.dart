import 'dart:math';

import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_node.dart';
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/models/optrain_repertoire.dart';
import 'package:mobx/mobx.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:e_trainer_chess/core/service_locator.dart';
import 'package:e_trainer_chess/core/localization/localization.store.dart';

part 'opening_trainer.store.g.dart';

class OpeningTrainerStore = OpeningTrainerStoreBase with _$OpeningTrainerStore;

enum PlayerMode { white, black, both }
enum VariationMode { random, select }

// NOVO: Classe para guardar o estado antes de cada lance
class AppTrainingSnapshot {
  final String fen;
  final Map<String, OpTrainNode>? nodeMoves;
  final String message;

  AppTrainingSnapshot(this.fen, this.nodeMoves, this.message);
}

abstract class OpeningTrainerStoreBase with Store {
  final chess_lib.Chess game = chess_lib.Chess();
  Map<String, OpTrainNode>? _currentNodeMoves;

  OpTrainRepertoire? currentRepertoire;

  // NOVO: Pilhas de histórico para Desfazer / Refazer
  final ObservableList<AppTrainingSnapshot> undoStack = ObservableList<AppTrainingSnapshot>();
  final ObservableList<AppTrainingSnapshot> redoStack = ObservableList<AppTrainingSnapshot>();

  @observable
  PlayerMode playerMode = PlayerMode.white;

  @observable
  VariationMode variationMode = VariationMode.random;

  @observable
  Map<String, OpTrainNode>? pendingVariations;

  @observable
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;

  String _lastValidFen = '';

  @observable
  bool showCoordinates = true;

  @observable
  bool allowBadMoves = false;

  @observable
  bool isAutoPlaying = false;

  @observable
  bool hasMadeWrongMove = false;

  @observable
  String currentMessage = "";

  @observable
  bool isTrainingFinished = false;

  @observable
  String? errorMessage;

  @computed
  bool get canUndo => undoStack.isNotEmpty;

  @computed
  bool get canRedo => redoStack.isNotEmpty;

  // Helper to fetch localized strings from the LocalizationStore
  String t(String key) => sl<LocalizationStore>().t(key);

  @action
  void toggleCoordinates() {
    showCoordinates = !showCoordinates;
  }

  @action
  void setAllowBadMoves(bool value) {
    allowBadMoves = value;
  }

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
    game.load(repertoire.initialFen);
    currentFen = game.fen;
    _lastValidFen = repertoire.initialFen;
    
    _currentNodeMoves = repertoire.expectedMoves;
    currentMessage = t('lineTool.trainer.training_started');
    isTrainingFinished = false;
    errorMessage = null;
    isAutoPlaying = false;
    hasMadeWrongMove = false;
    showCoordinates = true;
    
    // NOVO: Limpa histórico ao carregar nova abertura
    undoStack.clear();
    redoStack.clear();
    pendingVariations = null;

    _checkAutoMove();
  }

  @action
  void restartTraining() {
    if (currentRepertoire != null) {
      loadRepertoire(currentRepertoire!);
    }
  }

  // NOVO: Salva o estado atual antes de modificá-lo
  void _saveSnapshot() {
    undoStack.add(AppTrainingSnapshot(_lastValidFen, _currentNodeMoves, currentMessage));
    redoStack.clear(); // Ao fazer um novo lance, perde o refazer
  }

  @action
  void onUserMove(String from, String to, [String? promotion]) {
    if (isTrainingFinished || _currentNodeMoves == null) return;
    if (isAutoPlaying || hasMadeWrongMove) return;

    errorMessage = null;
    final String moveKey = promotion != null ? "$from$to$promotion" : "$from$to";

    if (_currentNodeMoves!.containsKey(moveKey)) {
      final nextNode = _currentNodeMoves![moveKey]!;

      _saveSnapshot(); // Salva estado ANTES de atualizar
      // Aplica o lance na engine interna e atualiza a fen reativa
      game.move({"from": from, "to": to, "promotion": promotion ?? 'q'});
      currentFen = game.fen;
      _lastValidFen = currentFen;

      _updateMessage(nextNode);
      _currentNodeMoves = nextNode.expectedMoves;

      if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
        isTrainingFinished = true;
        currentMessage = t('lineTool.trainer.training_finished_memorized');
      } else {
        _checkAutoMove();
      }
    } else {
      hasMadeWrongMove = true;
      errorMessage = t('lineTool.trainer.wrong_move');
    }
  }

  @action
  void undoWrongMove() {
    game.load(_lastValidFen);
    currentFen = game.fen;
    hasMadeWrongMove = false;
    errorMessage = null;
    currentMessage = t('lineTool.trainer.try_again');
  }

  // NOVO: Ação principal para voltar lances pelo teclado ou UI
  @action
  void undoMove() {
    // Se estiver na tela de lance errado, a seta esquerda apenas cancela o erro
    if (hasMadeWrongMove) {
      undoWrongMove();
      return;
    }
    
    if (undoStack.isEmpty) return;

    // Salva o estado atual na pilha de refazer
    redoStack.add(AppTrainingSnapshot(_lastValidFen, _currentNodeMoves, currentMessage));
    
    var prev = undoStack.removeLast();
    _applySnapshot(prev);

    // Lógica inteligente: Voltar dois lances se cair na vez da Engine
    if (_isEngineTurn() && undoStack.isNotEmpty) {
      redoStack.add(AppTrainingSnapshot(_lastValidFen, _currentNodeMoves, currentMessage));
      prev = undoStack.removeLast();
      _applySnapshot(prev);
    }

    _checkAutoMove();
  }

  // NOVO: Ação principal para avançar lances pelo teclado ou UI
  @action
  void redoMove() {
    if (redoStack.isEmpty) return;
    if (hasMadeWrongMove) undoWrongMove(); 

    undoStack.add(AppTrainingSnapshot(_lastValidFen, _currentNodeMoves, currentMessage));
    var next = redoStack.removeLast();
    _applySnapshot(next);

    // Se ao avançar cair na vez da Engine, avança mais um para devolver a vez pro usuário
    if (_isEngineTurn() && redoStack.isNotEmpty) {
      undoStack.add(AppTrainingSnapshot(_lastValidFen, _currentNodeMoves, currentMessage));
      next = redoStack.removeLast();
      _applySnapshot(next);
    }

    _checkAutoMove();
  }

  bool _isEngineTurn() {
    if (playerMode == PlayerMode.both) return false;
    final isWhiteTurn = _lastValidFen.contains(' w ');
    return (playerMode == PlayerMode.white && !isWhiteTurn) ||
           (playerMode == PlayerMode.black && isWhiteTurn);
  }

  void _applySnapshot(AppTrainingSnapshot snapshot) {
    game.load(snapshot.fen);
    currentFen = game.fen;
    _lastValidFen = snapshot.fen;
    _currentNodeMoves = snapshot.nodeMoves;
    currentMessage = snapshot.message;
    hasMadeWrongMove = false;
    errorMessage = null;
    isTrainingFinished = _currentNodeMoves == null || _currentNodeMoves!.isEmpty;
    isAutoPlaying = false;
    pendingVariations = null;
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

      currentMessage = "${t('lineTool.trainer.hint_play')} $movesStr";
    }
  }

  @action
  Future<void> _checkAutoMove() async {
    if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) return;

    final shouldAutoMove = _isEngineTurn();

    if (shouldAutoMove) {
      isAutoPlaying = true;
      final savedRepertoire = currentRepertoire;

      await Future.delayed(const Duration(milliseconds: 600));

      if (currentRepertoire != savedRepertoire || hasMadeWrongMove) {
        isAutoPlaying = false;
        return;
      }

      final availableMoves = _currentNodeMoves!.entries.where((entry) {
        final quality = entry.value.quality;
        if (quality == MoveQuality.bad && !allowBadMoves) return false;
        return true;
      }).map((e) => e.key).toList();

      if (availableMoves.isEmpty) {
        isAutoPlaying = false;
        errorMessage = t('lineTool.trainer.no_allowed_moves');
        return;
      }

      if (availableMoves.length > 1 && variationMode == VariationMode.select) {
        pendingVariations = _currentNodeMoves;
        isAutoPlaying = false;
        return;
      }

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

    _saveSnapshot(); // Salva estado ANTES do lance da engine

    try {
      // Aplica o lance na engine base e atualiza FEN
      game.move({"from": from, "to": to, "promotion": promotion ?? 'q'});
    } catch (e) {
      errorMessage = "${t('lineTool.trainer.internal_error_auto_move')} ($from -> $to): $e";
    }

    currentFen = game.fen;
    _lastValidFen = currentFen;
    _updateMessage(selectedNode);
    _currentNodeMoves = selectedNode.expectedMoves;

    if (_currentNodeMoves == null || _currentNodeMoves!.isEmpty) {
      isTrainingFinished = true;
      currentMessage = t('lineTool.trainer.training_finished');
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
    // No cleanup required for chess_lib.Chess
  }
}