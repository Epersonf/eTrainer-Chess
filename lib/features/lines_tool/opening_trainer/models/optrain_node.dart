import 'package:json_annotation/json_annotation.dart';

part 'optrain_node.g.dart';

// NOVO: Enum para a qualidade do lance
enum MoveQuality { good, bad }

@JsonSerializable()
class OpTrainNode {
  final String? name;
  final List<String>? possibleMessages;

  final Map<String, OpTrainNode>? expectedMoves;

  // NOVO: Qualidade do lance. Retrocompatível com defaultValue.
  @JsonKey(defaultValue: MoveQuality.good)
  final MoveQuality quality;

  OpTrainNode({
    this.name,
    this.possibleMessages,
    this.expectedMoves,
    this.quality = MoveQuality.good,
  });

  factory OpTrainNode.fromJson(Map<String, dynamic> json) => _$OpTrainNodeFromJson(json);

  Map<String, dynamic> toJson() => _$OpTrainNodeToJson(this);
}
