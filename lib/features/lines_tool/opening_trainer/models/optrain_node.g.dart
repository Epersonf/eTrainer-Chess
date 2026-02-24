// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optrain_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpTrainNode _$OpTrainNodeFromJson(Map<String, dynamic> json) => OpTrainNode(
  name: json['name'] as String?,
  possibleMessages: (json['possibleMessages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  expectedMoves: (json['expectedMoves'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, OpTrainNode.fromJson(e as Map<String, dynamic>)),
  ),
  quality:
      $enumDecodeNullable(_$MoveQualityEnumMap, json['quality']) ??
      MoveQuality.good,
);

Map<String, dynamic> _$OpTrainNodeToJson(OpTrainNode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'possibleMessages': instance.possibleMessages,
      'expectedMoves': instance.expectedMoves,
      'quality': _$MoveQualityEnumMap[instance.quality]!,
    };

const _$MoveQualityEnumMap = {MoveQuality.good: 'good', MoveQuality.bad: 'bad'};
