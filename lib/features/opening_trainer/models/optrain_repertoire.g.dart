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
      boardOrientation:
          $enumDecodeNullable(
            _$OpTrainColorEnumMap,
            json['boardOrientation'],
          ) ??
          OpTrainColor.white,
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
      'boardOrientation': _$OpTrainColorEnumMap[instance.boardOrientation]!,
      'expectedMoves': instance.expectedMoves,
    };

const _$OpTrainColorEnumMap = {
  OpTrainColor.white: 'white',
  OpTrainColor.black: 'black',
};
