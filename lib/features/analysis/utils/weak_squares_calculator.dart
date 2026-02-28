class WeakSquaresCalculator {
  /// Retorna as casas que são consideradas "Casas Fracas" (Buracos).
  /// Regra: A casa é atacada por um peão de uma cor, e não pode ser
  /// defendida por NENHUM peão da cor oposta (pois não há peões nas colunas
  /// adjacentes atrás dessa casa).
  static Set<String> getWeakSquares(String fen) {
    final board = List.generate(8, (_) => List<String?>.filled(8, null));
    final rows = fen.split(' ')[0].split('/');

    for (int r = 0; r < 8; r++) {
      int c = 0;
      for (int i = 0; i < rows[r].length; i++) {
        final char = rows[r][i];
        if (RegExp(r'[1-8]').hasMatch(char)) {
          c += int.parse(char);
        } else {
          board[r][c] = char;
          c++;
        }
      }
    }

    final weakSquares = <String>{};

    bool canWhiteDefend(int r, int c) {
      // Peões brancos sobem do índice 6 para 0.
      // Para defender (r, c), o peão branco deve estar em c-1 ou c+1, num índice MAIOR que r.
      for (int dc in [-1, 1]) {
        int pc = c + dc;
        if (pc >= 0 && pc < 8) {
          for (int pr = r + 1; pr < 8; pr++) {
            if (board[pr][pc] == 'P') return true;
          }
        }
      }
      return false;
    }

    bool canBlackDefend(int r, int c) {
      // Peões pretos descem do índice 1 para 7.
      // Para defender (r, c), o peão preto deve estar em c-1 ou c+1, num índice MENOR que r.
      for (int dc in [-1, 1]) {
        int pc = c + dc;
        if (pc >= 0 && pc < 8) {
          for (int pr = r - 1; pr >= 0; pr--) {
            if (board[pr][pc] == 'p') return true;
          }
        }
      }
      return false;
    }

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        bool attackedByWhitePawn = false;
        bool attackedByBlackPawn = false;

        // O peão branco ataca subindo (r + 1)
        if (r + 1 < 8) {
          if (c - 1 >= 0 && board[r + 1][c - 1] == 'P') attackedByWhitePawn = true;
          if (c + 1 < 8 && board[r + 1][c + 1] == 'P') attackedByWhitePawn = true;
        }

        // O peão preto ataca descendo (r - 1)
        if (r - 1 >= 0) {
          if (c - 1 >= 0 && board[r - 1][c - 1] == 'p') attackedByBlackPawn = true;
          if (c + 1 < 8 && board[r - 1][c + 1] == 'p') attackedByBlackPawn = true;
        }

        final squareName = '${String.fromCharCode(97 + c)}${8 - r}';

        // Buraco na defesa das Pretas
        if (attackedByWhitePawn && !canBlackDefend(r, c)) {
          weakSquares.add(squareName);
        }
        // Buraco na defesa das Brancas
        if (attackedByBlackPawn && !canWhiteDefend(r, c)) {
          weakSquares.add(squareName);
        }
      }
    }

    return weakSquares;
  }
}
