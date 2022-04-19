// ignore_for_file: avoid_dynamic_calls, avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:moor/moor_web.dart';

import '../../mixin_database.dart';

Future<MixinDatabase> constructDb(String _) async => MixinDatabase(
      WebDatabase.withStorage(
        await MoorWebStorage.indexedDbIfSupported('mixin'),
        logStatements: !kReleaseMode,
      ),
    );

Future<void> deleteDatabase(String _) async {
  // delete indexedDB;
  window.indexedDB?.deleteDatabase('moor_databases');

  // delete localStorage;
  window.localStorage.clear();
}
