// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optrain_repertoire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpTrainRepertoire _$OpTrainRepertoireFromJson(Map<String, dynamic> json) =>
    OpTrainRepertoire(
      initialFen:
          json['initialFen'] as String? ??
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      expectedMoves:
          (json['expectedMoves'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, OpTrainNode.fromJson(e as Map<String, dynamic>)),
          ) ??
          {},
    );

Map<String, dynamic> _$OpTrainRepertoireToJson(OpTrainRepertoire instance) =>
    <String, dynamic>{
      'initialFen': instance.initialFen,
      'expectedMoves': instance.expectedMoves,
    };
