import 'package:drift/drift.dart';

class MillisDateConverterNotnull extends TypeConverter<DateTime, int> {
  const MillisDateConverterNotnull();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}

class MillisDateConverter extends TypeConverter<DateTime?, int?> {
  const MillisDateConverter();

  @override
  DateTime? fromSql(int? fromDb) {
    if (fromDb == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);
  }

  @override
  int? toSql(DateTime? value) => value?.millisecondsSinceEpoch;
}
