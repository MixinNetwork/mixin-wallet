import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../mixin_database.dart';

part 'snapshot_dao.g.dart';

extension SnapshotConverter on sdk.Snapshot {
  SnapshotsCompanion get asDbSnapshotObject => SnapshotsCompanion.insert(
        snapshotId: snapshotId,
        type: type,
        assetId: assetId,
        amount: amount,
        createdAt: createdAt,
        opponentId: Value(opponentId),
        transactionHash: Value(transactionHash),
        sender: Value(sender),
        receiver: Value(receiver),
        memo: Value(memo),
        confirmations: Value(confirmations),
        traceId: Value(traceId),
      );
}

extension SnapshotConverterForPendingDeposit on sdk.PendingDeposit {
  Snapshot toSnapshot(String assetId) => Snapshot(
        snapshotId: transactionId,
        type: sdk.SnapshotType.pending,
        assetId: assetId,
        amount: amount,
        createdAt: createdAt,
        opponentId: null,
        transactionHash: transactionHash,
        sender: sender,
        receiver: null,
        memo: null,
        confirmations: confirmations,
      );
}

@DriftAccessor(tables: [Snapshots])
class SnapshotDao extends DatabaseAccessor<MixinDatabase>
    with _$SnapshotDaoMixin {
  SnapshotDao(MixinDatabase db) : super(db);

  Future<int> insert(Snapshot snapshot) =>
      into(db.snapshots).insertOnConflictUpdate(snapshot);

  Future<void> insertPendingDeposit(List<Snapshot> snapshots) =>
      batch((batch) => batch.insertAll(
            db.snapshots,
            snapshots,
            mode: InsertMode.insertOrReplace,
          ));

  Future<void> insertAll(List<sdk.Snapshot> snapshots) =>
      batch((batch) => batch.insertAll(
            db.snapshots,
            snapshots.map((e) => e.asDbSnapshotObject).toList(),
            mode: InsertMode.insertOrReplace,
          ));

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

  Selectable<SnapshotItem> snapshotsById(String snapshotId) => db.snapshotItems(
        (s, u, a) => s.snapshotId.equals(snapshotId),
        (s, u, a) => const OrderBy.nothing(),
        (s, u, a) => Limit(1, null),
      );

  Selectable<SnapshotItem> allSnapshots({
    int? offset,
    int limit = 30,
    bool orderByAmount = false,
    List<String> types = const [],
  }) =>
      db.snapshotItems(
        (s, u, a) {
          Expression<bool?> predicate = const Constant(true);
          if (types.isNotEmpty) {
            predicate &= s.type.isIn(types);
          }
          return predicate;
        },
        (s, u, a) => OrderBy([
          if (orderByAmount) OrderingTerm.desc(_AmountSqlExpression(s)),
          if (!orderByAmount) OrderingTerm.desc(s.createdAt),
          OrderingTerm.desc(s.snapshotId),
        ]),
        (s, u, a) => Limit(limit, offset),
      );

  Selectable<SnapshotItem> snapshots(
    String assetId, {
    int? offset,
    int limit = 30,
    bool orderByAmount = false,
    List<String> types = const [],
    String? opponent,
  }) =>
      db.snapshotItems(
        (s, u, a) {
          Expression<bool?> predicate = a.assetId.equals(assetId);
          if (types.isNotEmpty) {
            predicate &= s.type.isIn(types);
          }
          if (opponent != null) {
            predicate &= s.opponentId.equals(opponent);
          }
          return predicate;
        },
        (s, u, a) => OrderBy([
          if (orderByAmount) OrderingTerm.desc(_AmountSqlExpression(s)),
          if (!orderByAmount) OrderingTerm.desc(s.createdAt),
          OrderingTerm.desc(s.snapshotId),
        ]),
        (s, u, a) => Limit(limit, offset),
      );

  Future<int> clearPendingDepositsByAssetId(String assetId) => db
      .clearPendingDepositsBy((snapshots) => snapshots.assetId.equals(assetId));

  Selectable<String> snapshotIdsByTransactionHashList(
          String assetId, List<String> hashList) =>
      (select(db.snapshots)
            ..where(
              (tbl) =>
                  tbl.assetId.equals(assetId) &
                  tbl.type.equals('deposit') &
                  tbl.transactionHash.isIn(hashList),
            ))
          .map((e) => e.snapshotId);
}

class _AmountSqlExpression extends Expression<dynamic> {
  _AmountSqlExpression(this.s);

  final Snapshots s;

  @override
  void writeInto(GenerationContext context) {
    context.buffer.write('abs(${s.amount.escapedName})');
  }
}
