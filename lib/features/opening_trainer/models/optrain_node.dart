import 'package:json_annotation/json_annotation.dart';

part 'optrain_node.g.dart';

@JsonSerializable()
class OpTrainNode {
  @JsonKey(defaultValue: 'AUTO')
  final String type;

  final List<String>? possibleMessages;

  final Map<String, OpTrainNode>? expectedMoves;

  OpTrainNode({
    required this.type,
    this.possibleMessages,
    this.expectedMoves,
  });

  factory OpTrainNode.fromJson(Map<String, dynamic> json) => _$OpTrainNodeFromJson(json);

  Map<String, dynamic> toJson() => _$OpTrainNodeToJson(this);
}
