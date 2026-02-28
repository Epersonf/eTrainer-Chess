import '../models/square_stats.dart';

class HeatmapCalculator {
  /// Analisa o FEN e calcula quantas peças atacam e defendem cada casa.
  static Map<String, SquareStats> calculate(String fen) {
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

    final whiteAttacks = List.generate(8, (_) => List<int>.filled(8, 0));
    final blackAttacks = List.generate(8, (_) => List<int>.filled(8, 0));

    void addControl(int r, int c, bool isWhite) {
      if (r >= 0 && r < 8 && c >= 0 && c < 8) {
        if (isWhite) {
          whiteAttacks[r][c]++;
        } else {
          blackAttacks[r][c]++;
        }
      }
    }

    void castRay(int r, int c, int dr, int dc, bool isWhite) {
      int currR = r + dr;
      int currC = c + dc;
      while (currR >= 0 && currR < 8 && currC >= 0 && currC < 8) {
        addControl(currR, currC, isWhite);
        if (board[currR][currC] != null) break;
        currR += dr;
        currC += dc;
      }
    }

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p == null) continue;

        final isWhite = p == p.toUpperCase();
        final type = p.toLowerCase();

        if (type == 'p') {
          int dr = isWhite ? -1 : 1;
          addControl(r + dr, c - 1, isWhite);
          addControl(r + dr, c + 1, isWhite);
        } else if (type == 'n') {
          final jumps = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]];
          for (var j in jumps) addControl(r + j[0], c + j[1], isWhite);
        } else if (type == 'k') {
          final steps = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]];
          for (var s in steps) addControl(r + s[0], c + s[1], isWhite);
        } else if (type == 'r') {
          final dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
          for (var d in dirs) castRay(r, c, d[0], d[1], isWhite);
        } else if (type == 'b') {
          final dirs = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
          for (var d in dirs) castRay(r, c, d[0], d[1], isWhite);
        } else if (type == 'q') {
          final dirs = [[-1, -1], [-1, 1], [1, -1], [1, 1], [-1, 0], [1, 0], [0, -1], [0, 1]];
          for (var d in dirs) castRay(r, c, d[0], d[1], isWhite);
        }
      }
    }

    final result = <String, SquareStats>{};
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final file = String.fromCharCode(97 + c);
        final rank = 8 - r;
        final square = '$file$rank';

        final p = board[r][c];
        int attacks = 0;
        int defenses = 0;

        if (p != null) {
          final isWhite = p == p.toUpperCase();
          attacks = isWhite ? blackAttacks[r][c] : whiteAttacks[r][c];
          defenses = isWhite ? whiteAttacks[r][c] : blackAttacks[r][c];
        } else {
          attacks = whiteAttacks[r][c];
          defenses = blackAttacks[r][c];
        }

        if (attacks > 0 || defenses > 0) {
          result[square] = SquareStats(attacks, defenses);
        }
      }
    }
    return result;
  }
}
