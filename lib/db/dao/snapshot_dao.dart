import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

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

  Future<int> insert(Snapshot snapshot) =>
      into(db.snapshots).insertOnConflictUpdate(snapshot);

  Future<void> insertAll(List<sdk.Snapshot> snapshots) =>
      batch((batch) => batch.insertAll(
            db.snapshots,
            snapshots.map((e) => e.asDbSnapshotObject).toList(),
            mode: InsertMode.insertOrReplace,
          ));

  Future deleteSnapshot(Snapshot snapshot) =>
      delete(db.snapshots).delete(snapshot);

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
