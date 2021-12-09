import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

import '../converter/deposit_entry_converter.dart';
import '../mixin_database.dart';
import '../util/util.dart';

part 'asset_dao.g.dart';

extension AssetConverter on sdk.Asset {
  AssetsCompanion get asAssetsCompanion => AssetsCompanion.insert(
        assetId: assetId,
        symbol: symbol,
        name: name,
        iconUrl: iconUrl,
        balance: balance,
        destination: Value(destination),
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
            Value(const DepositEntryConverter().mapToSql(depositEntries)),
      );

  AssetsCompanion get asAssetsCompanionWithoutBalance => AssetsCompanion(
        assetId: Value(assetId),
        symbol: Value(symbol),
        name: Value(name),
        iconUrl: Value(iconUrl),
        destination: Value(destination),
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
            Value(const DepositEntryConverter().mapToSql(depositEntries)),
      );
}

@UseDao(tables: [Assets])
class AssetDao extends DatabaseAccessor<MixinDatabase> with _$AssetDaoMixin {
  AssetDao(MixinDatabase db) : super(db);

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
        (asset, _, ae, f) => ignoreWhere,
        (_, __, ___, f) => ignoreOrderBy,
        (_, __, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResultsNotHidden(String currentFiat) =>
      db.assetResults(
        currentFiat,
        (asset, _, ae, f) => ae.hidden.isNull() | ae.hidden.equals(false),
        (_, __, ___, f) => ignoreOrderBy,
        (_, __, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResultsOfIn(
          String currentFiat, Iterable<String> assetIds) =>
      db.assetResults(
        currentFiat,
        (asset, _, __, f) => asset.assetId.isIn(assetIds),
        (_, __, ___, f) => ignoreOrderBy,
        (_, __, ___, f) => maxLimit,
      );

  Selectable<AssetResult> searchAssetResults(
          String currentFiat, String keyword) =>
      db.assetResults(
        currentFiat,
        (asset, _, __, ae) {
          if (keyword.isEmpty) {
            return ignoreWhere;
          }
          final regex = '%$keyword%';
          return asset.symbol.like(regex) | asset.name.like(regex);
        },
        (asset, _, __, f) {
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
        (_, __, ___, f) => maxLimit,
      );

  Selectable<AssetResult> assetResult(String currentFiat, String assetId) =>
      db.assetResults(
          currentFiat,
          (Assets asset, _, __, ___) => asset.assetId.equals(assetId),
          (_, __, ___, f) => ignoreOrderBy,
          (_, __, ___, f) => Limit(1, null));

  Selectable<Asset> simpleAssetById(String assetId) => select(db.assets)
    ..where((tbl) => tbl.assetId.equals(assetId))
    ..limit(1);

  Selectable<AssetResult> hiddenAssets(String currentFiat) => db.assetResults(
        currentFiat,
        (asset, tempAsset, ae, fiat) => ae.hidden.equals(true),
        (asset, tempAsset, ae, fiat) => ignoreOrderBy,
        (asset, tempAsset, ae, fiat) => maxLimit,
      );
}
