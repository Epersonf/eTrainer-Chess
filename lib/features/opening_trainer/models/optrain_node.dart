import 'package:json_annotation/json_annotation.dart';

part 'optrain_node.g.dart';

@JsonSerializable()
class OpTrainNode {
  final List<String>? possibleMessages;

  final Map<String, OpTrainNode>? expectedMoves;

  OpTrainNode({
    this.possibleMessages,
    this.expectedMoves,
  });

  factory OpTrainNode.fromJson(Map<String, dynamic> json) => _$OpTrainNodeFromJson(json);

  Map<String, dynamic> toJson() => _$OpTrainNodeToJson(this);
}
