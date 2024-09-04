// ignore_for_file: avoid_dynamic_calls, avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import '../../../util/logger.dart';
import '../../mixin_database.dart';

DatabaseConnection connectOnWeb() =>
    DatabaseConnection.delayed(Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'mixin',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        // Depending how central local persistence is to your app, you may want
        // to show a warning to the user if only unrealiable implemetentations
        // are available.
        i('Using ${result.chosenImplementation} due to missing browser '
            'features: ${result.missingFeatures}');
      }

      return result.resolvedExecutor;
    }));

Future<MixinDatabase> constructDb(String _) async =>
    MixinDatabase(connectOnWeb());

Future<void> deleteDatabase(String _) async {
  // delete indexedDB;
  window.indexedDB?.deleteDatabase('moor_databases');

  // delete localStorage;
  window.localStorage.clear();
}
