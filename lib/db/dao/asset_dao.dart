import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../converter/deposit_entry_converter.dart';
import '../mixin_database.dart';
import '../util/util.dart';
import 'extension.dart';

part 'asset_dao.g.dart';

AssetResults$orderBy defaultOrderBy = (asset, _, c, __, f) {
  final balance = '${asset.aliasedName}.${asset.balance.$name}';
  final priceUsd = '${asset.aliasedName}.${asset.priceUsd.$name}';

  return OrderBy([
    OrderingTerm.desc(CustomExpression('''
    CASE WHEN $balance > 0 THEN $balance * $priceUsd END
    ''')),
    OrderingTerm.desc(asset.balance.cast<double>()),
    OrderingTerm.desc(asset.priceUsd.cast<double>()),
  ]);
};

extension AssetConverter on sdk.Asset {
  AssetsCompanion get asAssetsCompanion => AssetsCompanion.insert(
        assetId: assetId,
        symbol: symbol,
        name: name,
        iconUrl: iconUrl,
        balance: Value(balance),
        destination: Value(getDestination()),
        tag: Value(tag),
        assetKey: Value(assetKey),
        priceBtc: priceBtc,
        priceUsd: priceUsd,
        chainId: chainId,
        changeUsd: changeUsd,
        changeBtc: changeBtc,
        confirmations: confirmations,
        reserve: Value(reserve),
        depositEntries:
            Value(const DepositEntryConverter().toSql(depositEntries)),
      );

  AssetsCompanion get asAssetsCompanionWithoutBalance => AssetsCompanion(
        assetId: Value(assetId),
        symbol: Value(symbol),
        name: Value(name),
        iconUrl: Value(iconUrl),
        destination: Value(getDestination()),
        tag: Value(tag),
        assetKey: Value(assetKey),
        priceBtc: Value(priceBtc),
        priceUsd: Value(priceUsd),
        chainId: Value(chainId),
        changeUsd: Value(changeUsd),
        changeBtc: Value(changeBtc),
        confirmations: Value(confirmations),
        reserve: Value(reserve),
        depositEntries:
            Value(const DepositEntryConverter().toSql(depositEntries)),
      );
}

@DriftAccessor(tables: [Assets])
class AssetDao extends DatabaseAccessor<MixinDatabase> with _$AssetDaoMixin {
  AssetDao(super.db);

  Future<int> insert(sdk.Asset asset) =>
      into(db.assets).insertOnConflictUpdate(asset.asAssetsCompanion);

  Future<void> deleteAsset(Asset asset) => delete(db.assets).delete(asset);

  Future<void> insertAllOnConflictUpdateWithoutBalance(
      List<sdk.Asset> assets) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.assets,
        assets.map((asset) => asset.asAssetsCompanionWithoutBalance).toList(),
      );
    });
  }

  Future<void> insertAllOnConflictUpdate(List<sdk.Asset> assets) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.assets,
        assets.map((asset) => asset.asAssetsCompanion).toList(),
      );
    });
  }

  Future<void> resetAllBalance() async {
    await db.update(db.assets).write(const AssetsCompanion(
          balance: Value('0.0'),
        ));
  }

  Selectable<AssetResult> assetResults(String currentFiat) => db.assetResults(
        currentFiat,
        (asset, _, c, ae, f) => ignoreWhere,
        defaultOrderBy,
        (_, __, c, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResultsWithBalance(String currentFiat) =>
      db.assetResults(
        currentFiat,
        (asset, _, c, ae, f) =>
            asset.balance.isNotNull() &
            asset.balance.isNotIn(const ['0', '0.0']),
        defaultOrderBy,
        (_, __, c, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResultsNotHidden(String currentFiat) =>
      db.assetResults(
        currentFiat,
        (asset, _, c, ae, f) =>
            (ae.hidden.isNull() | ae.hidden.equals(false)) &
            ((asset.balance.isNotNull() &
                    asset.balance.isNotIn(const ['0', '0.0'])) |
                asset.assetId.equalsExp(asset.chainId)),
        defaultOrderBy,
        (_, __, c, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResultsOfIn(
          String currentFiat, Iterable<String> assetIds) =>
      db.assetResults(
        currentFiat,
        (asset, _, c, __, f) => asset.assetId.isIn(assetIds),
        defaultOrderBy,
        (_, __, c, ___, f) => maxLimit,
      );

  Selectable<AssetResult> searchAssetResults(
          String currentFiat, String keyword) =>
      db.assetResults(
        currentFiat,
        (asset, _, c, __, ae) {
          if (keyword.isEmpty) {
            return ignoreWhere;
          }
          final regex = '%$keyword%';
          return asset.symbol.like(regex) | asset.name.like(regex);
        },
        (asset, _, c, __, f) {
          final symbol = '${asset.aliasedName}.${asset.symbol.$name}';
          final name = '${asset.aliasedName}.${asset.name.$name}';
          return OrderBy([
            OrderingTerm.asc(CustomExpression('''
(
CASE
WHEN $symbol = '$keyword' THEN 1
WHEN $name = '$keyword' THEN 1
WHEN $symbol LIKE '$keyword%' THEN 100 + LENGTH($symbol)
WHEN $name LIKE '$keyword%' THEN 100 + LENGTH($name)
WHEN $symbol LIKE '%$keyword%' THEN 200 + LENGTH($symbol)
WHEN $name LIKE '%$keyword%' THEN 200 + LENGTH($name)
WHEN $symbol LIKE '%$keyword' THEN 300 + LENGTH($symbol)
WHEN $name LIKE '%$keyword' THEN 300 + LENGTH($name)
ELSE 1000 END
)
          ''')),
            OrderingTerm.desc(asset.priceUsd.isBiggerThanValue('0')),
            OrderingTerm.asc(asset.symbol),
            OrderingTerm.asc(asset.name),
          ]);
        },
        (_, __, c, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResult(String currentFiat, String assetId) =>
      db.assetResults(
          currentFiat,
          (Assets asset, _, c, __, ___) => asset.assetId.equals(assetId),
          (_, __, c, ___, f) => ignoreOrderBy,
          (_, __, c, ___, f) => Limit(1, null));

  Selectable<Asset> simpleAssetById(String assetId) => select(db.assets)
    ..where((tbl) => tbl.assetId.equals(assetId))
    ..limit(1);

  Selectable<AssetResult> hiddenAssets(String currentFiat) => db.assetResults(
        currentFiat,
        (asset, tempAsset, c, ae, fiat) => ae.hidden.equals(true),
        (asset, tempAsset, c, ae, fiat) => ignoreOrderBy,
        (asset, tempAsset, c, ae, fiat) => maxLimit,
      );

  Future<String?> findAssetIdByAssetKey(String assetKey) =>
      db.findAssetIdByAssetKey(assetKey).getSingleOrNull();
}
