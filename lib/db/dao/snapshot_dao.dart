import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

import '../database_event_bus.dart';
import '../mixin_database.dart';

part 'snapshot_dao.g.dart';

extension SnapshotConverter on sdk.Snapshot {
  SnapshotsCompanion get asDbSnapshotObject => SnapshotsCompanion.insert(
        snapshotId: snapshotId,
        type: type,
        assetId: assetId,
        amount: amount,
        createdAt: createdAt,
      );
}

@UseDao(tables: [Snapshots])
class SnapshotDao extends DatabaseAccessor<MixinDatabase>
    with _$SnapshotDaoMixin {
  SnapshotDao(MixinDatabase db) : super(db);

  late Stream<List<SnapshotItem>> updateTransactionStream = db.eventBus
      .watch<Iterable<String>>(DatabaseEvent.updateTransaction)
      .asyncMap(
        (event) => snapshotsByIds(event.toList()).get(),
      )
      .distinct();

  Future<int> insert(Snapshot snapshot) => _updateSnapshots(
      [snapshot.snapshotId],
      into(db.snapshots).insertOnConflictUpdate(snapshot));

  Future<void> insertAll(List<sdk.Snapshot> snapshots) => _updateSnapshots(
      snapshots.map((e) => e.snapshotId).toList(),
      batch((batch) => batch.insertAll(
            db.snapshots,
            snapshots.map((e) => e.asDbSnapshotObject).toList(),
            mode: InsertMode.insertOrReplace,
          )));

  Future<T> _updateSnapshots<T>(
      List<String> snapshotIds, Future<T> future) async {
    final ret = await future;
    db.eventBus.send(DatabaseEvent.updateTransaction, snapshotIds);
    return ret;
  }

  Future deleteSnapshot(Snapshot snapshot) =>
      delete(db.snapshots).delete(snapshot);

  Selectable<SnapshotItem> snapshotsByIds(List<String> snapshotIds) =>
      db.snapshotItems(
        (s, u, a) => s.snapshotId.isIn(snapshotIds),
        (s, u, a) => OrderBy([
          OrderingTerm.desc(s.createdAt),
          OrderingTerm.desc(s.snapshotId),
        ]),
        (s, u, a) => Limit(snapshotIds.length, null),
      );

  Selectable<SnapshotItem> snapshots(
    String assetId, {
    String? offset,
    int count = 30,
  }) =>
      db.snapshotItems(
        (s, u, a) {
          final assetPredicate = a.assetId.equals(assetId);
          if (offset == null) {
            return assetPredicate;
          }
          return assetPredicate &
              s.createdAt.isSmallerThan(
                Variable(DateTime.parse(offset).millisecondsSinceEpoch),
              );
        },
        (s, u, a) => OrderBy([
          OrderingTerm.desc(s.createdAt),
          OrderingTerm.desc(s.snapshotId),
        ]),
        (s, u, a) => Limit(count, null),
      );
}
