import 'package:drift/web.dart';
import 'package:web/web.dart';

import '../../mixin_database.dart';

Future<MixinDatabase> constructDb(String _) async => MixinDatabase(
      WebDatabase.withStorage(
        await DriftWebStorage.indexedDbIfSupported('mixin'),
        logStatements: false,
      ),
    );

Future<void> deleteDatabase(String _) async {
  // delete indexedDB;
  window.indexedDB.deleteDatabase('moor_databases');

  // delete localStorage;
  window.localStorage.clear();
}
