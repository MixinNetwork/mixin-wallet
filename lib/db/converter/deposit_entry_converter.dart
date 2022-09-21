import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

class DepositEntryConverter
    extends TypeConverter<List<DepositEntry>?, String?> {
  const DepositEntryConverter();

  @override
  List<DepositEntry>? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    final data = json.decode(fromDb) as List<dynamic>;
    return data
        .map((dynamic e) => DepositEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String? toSql(List<DepositEntry>? value) {
    if (value == null) return null;
    return json.encode(value);
  }
}
