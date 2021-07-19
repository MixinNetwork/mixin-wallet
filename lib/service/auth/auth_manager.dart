import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'auth.dart';

Future<void> initAuthManager() async {
  Hive.registerAdapter(_AuthAdapter());
  await Hive.initFlutter();
  await Hive.openBox('settings');
}

Auth? get auth => Hive.box('settings').get('auth') as Auth?;

Future<void> setAuth(Auth? value) => Hive.box('settings').put('auth', value);

String? get accessToken => auth?.accessToken;

bool get isLogin => accessToken != null;

class _AuthAdapter extends TypeAdapter<Auth> {
  @override
  Auth read(BinaryReader reader) => Auth.fromJson(reader
      .readMap()
      .map((key, value) => MapEntry<String, dynamic>(key, value)));

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Auth obj) {
    writer.writeMap(obj.toJson());
  }
}
