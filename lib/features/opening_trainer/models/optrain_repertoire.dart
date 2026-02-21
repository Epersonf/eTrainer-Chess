import 'package:json_annotation/json_annotation.dart';
import 'optrain_node.dart';

part 'optrain_repertoire.g.dart';

// NOVO: Enum para a orientação do tabuleiro
enum OpTrainColor {
  @JsonValue('white')
  white,
  @JsonValue('black')
  black,
}

@JsonSerializable()
class OpTrainRepertoire {
  @JsonKey(defaultValue: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
  final String initialFen;

  // NOVO: Atributo para forçar a orientação no arquivo .optrain
  @JsonKey(defaultValue: OpTrainColor.white)
  final OpTrainColor boardOrientation;

  @JsonKey(defaultValue: <String, OpTrainNode>{})
  final Map<String, OpTrainNode> expectedMoves;

  OpTrainRepertoire({
    required this.initialFen,
    this.boardOrientation = OpTrainColor.white,
    required this.expectedMoves,
  });

  factory OpTrainRepertoire.fromJson(Map<String, dynamic> json) => _$OpTrainRepertoireFromJson(json);

  Map<String, dynamic> toJson() => _$OpTrainRepertoireToJson(this);
}
