import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';

import '../../../util/file.dart';
import '../../mixin_database.dart';

LazyDatabase _openConnection(File dbFile) =>
    LazyDatabase(() => NativeDatabase(dbFile));

Future<MixinDatabase> constructDb(String identityNumber) async {
  final dbFolder = await getMixinDocumentsDirectory();
  final dbFile = File(join(dbFolder.path, identityNumber, 'mixin.db'));
  final moorIsolate = await _createMoorIsolate(dbFile);
  final databaseConnection = await moorIsolate.connect();
  return MixinDatabase.connect(databaseConnection);
}

Future<void> deleteDatabase(String identityNumber) async {
  final dbFolder = await getMixinDocumentsDirectory();
  final dbFile = File(join(dbFolder.path, identityNumber, 'mixin.db'));
  await dbFile.delete();
}

Future<DriftIsolate> _createMoorIsolate(File dbFile) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startBackground,
    _IsolateStartRequest(receivePort.sendPort, dbFile),
  );

  return await receivePort.first as DriftIsolate;
}

void _startBackground(_IsolateStartRequest request) {
  final executor = _openConnection(request.dbFile);
  final moorIsolate = DriftIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );
  request.sendMoorIsolate.send(moorIsolate);
}

class _IsolateStartRequest {
  _IsolateStartRequest(this.sendMoorIsolate, this.dbFile);

  final SendPort sendMoorIsolate;
  final File dbFile;
}
