import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../util/web/web_utils_dummy.dart'
    if (dart.library.html) '../../util/web/web_utils.dart';
import 'auth.dart';

Future<void> initStorage() async {
  Hive.registerAdapter(_AuthAdapter());
  await Hive.initFlutter();
  fixSafariIndexDb();
  await Hive.openBox('profile');
}

Auth? get auth => profileBox.get('auth') as Auth?;

Future<void> setAuth(Auth? value) => profileBox.put('auth', value);

Box<dynamic> get profileBox => Hive.box('profile');

String? get accessToken => auth?.accessToken;

bool get isLogin => accessToken != null;

List<String> get searchAssetHistory =>
    ((profileBox.get('searchAssetHistory') as List<dynamic>?) ?? [])
        .map((e) => e as String)
        .toList();

void putSearchAssetHistory(String assetId) {
  final list = searchAssetHistory;
  profileBox.put('searchAssetHistory', [
    assetId,
    if (list.isNotEmpty) list.first,
  ]);
}

List<String> get topAssetIds =>
    ((profileBox.get('topAssetIds') as List<dynamic>?) ?? [])
        .map((e) => e as String)
        .toList();

void replaceTopAssetIds(List<String> topAssetIds) =>
    profileBox.put('topAssetIds', topAssetIds);

class _AuthAdapter extends TypeAdapter<Auth> {
  @override
  Auth read(BinaryReader reader) => Auth.fromJson(reader
      .readMap()
      .map((key, value) => MapEntry<String, dynamic>(key as String, value)));

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Auth obj) {
    writer.writeMap(obj.toJson());
  }
}
