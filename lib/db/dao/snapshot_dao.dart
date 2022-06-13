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
        db.snapshots.snapshotId.isIn(snapshotIds),
        OrderBy([
          OrderingTerm.desc(db.snapshots.createdAt),
          OrderingTerm.desc(db.snapshots.snapshotId),
        ]),
        Limit(snapshotIds.length, null),
      );

  Selectable<SnapshotItem> snapshotsById(String snapshotId) => db.snapshotItems(
        db.snapshots.snapshotId.equals(snapshotId),
        const OrderBy.nothing(),
        Limit(1, null),
      );

  Expression<bool?> _allSnapshotsWhere(
      List<String> types, Snapshots snapshots) {
    Expression<bool?> predicate = const Constant(true);
    if (types.isNotEmpty) {
      predicate &= snapshots.type.isIn(types);
    }
    return predicate;
  }

  Selectable<SnapshotItem> allSnapshots({
    int? offset,
    int limit = 30,
    bool orderByAmount = false,
    List<String> types = const [],
  }) =>
      db.snapshotItems(
        _allSnapshotsWhere(types, db.snapshots),
        OrderBy([
          if (orderByAmount)
            OrderingTerm.desc(_AmountSqlExpression(db.snapshots)),
          if (!orderByAmount) OrderingTerm.desc(db.snapshots.createdAt),
          OrderingTerm.desc(db.snapshots.snapshotId),
        ]),
        Limit(limit, offset),
      );
  Expression<bool?> _snapshotsWhere(String assetId, List<String> types,
      Snapshots snapshots, String? opponent) {
    Expression<bool?> predicate = snapshots.assetId.equals(assetId);
    if (types.isNotEmpty) {
      predicate &= snapshots.type.isIn(types);
    }
    if (opponent != null) {
      predicate &= snapshots.opponentId.equals(opponent);
    }
    return predicate;
  }

  Selectable<SnapshotItem> snapshots(
    String assetId, {
    int? offset,
    int limit = 30,
    bool orderByAmount = false,
    List<String> types = const [],
    String? opponent,
  }) =>
      db.snapshotItems(
        _snapshotsWhere(assetId, types, db.snapshots, opponent),
        OrderBy([
          if (orderByAmount)
            OrderingTerm.desc(_AmountSqlExpression(db.snapshots)),
          if (!orderByAmount) OrderingTerm.desc(db.snapshots.createdAt),
          OrderingTerm.desc(db.snapshots.snapshotId),
        ]),
        Limit(limit, offset),
      );

  Future<int> clearPendingDepositsByAssetId(String assetId) =>
      db.clearPendingDepositsBy(db.snapshots.assetId.equals(assetId));

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
