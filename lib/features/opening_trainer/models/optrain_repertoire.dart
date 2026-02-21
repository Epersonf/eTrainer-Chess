import 'package:json_annotation/json_annotation.dart';
import 'optrain_node.dart';

part 'optrain_repertoire.g.dart';

@JsonSerializable()
class OpTrainRepertoire {
  @JsonKey(defaultValue: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
  final String initialFen;

  @JsonKey(defaultValue: <String, OpTrainNode>{})
  final Map<String, OpTrainNode> expectedMoves;

  OpTrainRepertoire({
    required this.initialFen,
    required this.expectedMoves,
  });

  factory OpTrainRepertoire.fromJson(Map<String, dynamic> json) => _$OpTrainRepertoireFromJson(json);

  Map<String, dynamic> toJson() => _$OpTrainRepertoireToJson(this);
}
