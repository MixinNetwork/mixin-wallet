import 'dart:convert';

import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:moor/moor.dart';

class DepositEntryConverter extends TypeConverter<List<DepositEntry>, String> {
  const DepositEntryConverter();

  @override
  List<DepositEntry>? mapToDart(String? fromDb) {
    if (fromDb == null) return null;
    final data = json.decode(fromDb) as List<dynamic>;
    return data
        .map((dynamic e) => DepositEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String? mapToSql(List<DepositEntry>? value) {
    if (value == null) return null;
    return json.encode(value);
  }
}
