import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../util/web/web_utils.dart';
import 'auth.dart';

Future<void> initStorage() async {
  Hive.registerAdapter(_AuthAdapter());
  await Hive.initFlutter();
  fixSafariIndexDb();
  await Hive.openBox<dynamic>('profile');
  await Hive.openBox<dynamic>('swap');
  await Hive.openBox<dynamic>('session');
}

Auth? get auth => profileBox.get('auth') as Auth?;

Future<void> setAuth(Auth? value) => profileBox.put('auth', value);

Box<dynamic> get profileBox => Hive.box('profile');

String? get accessToken => auth?.accessToken;

bool get isLogin => accessToken != null || auth?.credential != null;

bool get isLoginByCredential => auth?.credential != null;

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

bool get _isSmallAssetsHidden {
  final ret = profileBox.get('isSmallAssetsHidden');
  return (ret is bool ? ret : null) ?? false;
}

set _isSmallAssetsHidden(bool value) =>
    profileBox.put('isSmallAssetsHidden', value);

final ValueNotifier<bool> isSmallAssetsHidden = () {
  final notifier = ValueNotifier(_isSmallAssetsHidden);
  notifier.addListener(() {
    _isSmallAssetsHidden = notifier.value;
  });
  return notifier;
}();

String? get lastSelectedAddress =>
    profileBox.get('lastSelectedAddress') as String?;

set lastSelectedAddress(String? value) =>
    profileBox.put('lastSelectedAddress', value);

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
