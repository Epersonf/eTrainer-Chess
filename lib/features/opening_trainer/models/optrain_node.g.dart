// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optrain_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpTrainNode _$OpTrainNodeFromJson(Map<String, dynamic> json) => OpTrainNode(
  type: json['type'] as String? ?? 'AUTO',
  possibleMessages: (json['possibleMessages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  expectedMoves: (json['expectedMoves'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, OpTrainNode.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$OpTrainNodeToJson(OpTrainNode instance) =>
    <String, dynamic>{
      'type': instance.type,
      'possibleMessages': instance.possibleMessages,
      'expectedMoves': instance.expectedMoves,
    };
