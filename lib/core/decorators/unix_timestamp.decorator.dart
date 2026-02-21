import 'package:json_annotation/json_annotation.dart';

DateTime _parse(dynamic json) {
  if (json is DateTime) return json;
  if (json is int) {
    return DateTime.fromMillisecondsSinceEpoch(json); // milissegundos direto
  }
  if (json is String) return DateTime.parse(json);
  throw FormatException('Invalid date format: $json');
}

int? _toJsEpoch(DateTime? date) => date?.millisecondsSinceEpoch;

/// Nullable converter (int? <-> DateTime?)
class UnixDateTimeNullableConverter implements JsonConverter<DateTime?, int?> {
  const UnixDateTimeNullableConverter();

  @override
  DateTime? fromJson(dynamic json) => json == null ? null : _parse(json);

  @override
  int? toJson(DateTime? object) => _toJsEpoch(object);
}

/// Non-nullable converter (int <-> DateTime)
class UnixDateTimeConverter implements JsonConverter<DateTime, int> {
  const UnixDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) => _parse(json);

  @override
  int toJson(DateTime object) => _toJsEpoch(object)!;
}
