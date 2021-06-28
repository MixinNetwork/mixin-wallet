import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:moor/ffi.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;

import '../util/file.dart';
import 'dao/address_dao.dart';
import 'dao/asset_dao.dart';
import 'dao/snapshot_dao.dart';
import 'dao/user_dao.dart';
import 'database_event_bus.dart';

part 'mixin_database.g.dart';

@UseMoor(
  include: {
    'moor/mixin.moor',
  },
  daos: [
    AddressDao,
    AssetDao,
    SnapshotDao,
    UserDao,
  ],
  queries: {},
)
class MixinDatabase extends _$MixinDatabase {
  MixinDatabase.connect(DatabaseConnection c) : super.connect(c);

  @override
  int get schemaVersion => 1;

  final eventBus = DataBaseEventBus();

  @override
  MigrationStrategy get migration => MigrationStrategy(beforeOpen: (_) async {
        if (executor.dialect == SqlDialect.sqlite) {
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');
        }
      });
}

LazyDatabase _openConnection(File dbFile) =>
    LazyDatabase(() => VmDatabase(dbFile));

Future<MixinDatabase> createMoorIsolate(String identityNumber) async {
  final dbFolder = await getMixinDocumentsDirectory();
  final dbFile = File(p.join(dbFolder.path, identityNumber, 'mixin.db'));
  final moorIsolate = await _createMoorIsolate(dbFile);
  final databaseConnection = await moorIsolate.connect();
  return MixinDatabase.connect(databaseConnection);
}

Future<MoorIsolate> _createMoorIsolate(File dbFile) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startBackground,
    _IsolateStartRequest(receivePort.sendPort, dbFile),
  );

  return await receivePort.first as MoorIsolate;
}

void _startBackground(_IsolateStartRequest request) {
  final executor = _openConnection(request.dbFile);
  final moorIsolate = MoorIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );
  request.sendMoorIsolate.send(moorIsolate);
}

class _IsolateStartRequest {
  _IsolateStartRequest(this.sendMoorIsolate, this.dbFile);

  final SendPort sendMoorIsolate;
  final File dbFile;
}
