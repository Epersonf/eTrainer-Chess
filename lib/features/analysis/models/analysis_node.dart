class AnalysisNode {
  final String san; // O lance em notação algébrica (ex: Nf3)
  final String fen; // A posição resultante após este lance
  String? comment; // Comentários do PGN
  
  // Usamos um Map com a chave sendo o lance em UCI (ex: e2e4) para ramificar
  Map<String, AnalysisNode> variations;

  AnalysisNode({
    required this.san,
    required this.fen,
    this.comment,
    Map<String, AnalysisNode>? variations,
  }) : variations = variations ?? {};
}
