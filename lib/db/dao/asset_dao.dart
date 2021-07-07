import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

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
      );
}

@UseDao(tables: [Assets])
class AssetDao extends DatabaseAccessor<MixinDatabase> with _$AssetDaoMixin {
  AssetDao(MixinDatabase db) : super(db);

  Future<int> insert(sdk.Asset asset) =>
      into(db.assets).insertOnConflictUpdate(asset.asAssetsCompanion);

  Future deleteAsset(Asset asset) => delete(db.assets).delete(asset);

  Future<void> insertAllOnConflictUpdate(List<sdk.Asset> assets) async {
    await db.update(db.assets).write(const AssetsCompanion(
          balance: Value('0.0'),
        ));
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.assets,
        assets.map((asset) => asset.asAssetsCompanion).toList(),
      );
    });
  }

  Selectable<AssetResult> assetResults(String currentFiat) => db.assetResults(
      currentFiat,
      (_, __, ___) => ignoreWhere,
      (_, __, ___) => maxLimit);

  Selectable<AssetResult> assetResult(String currentFiat, String assetId) =>
      db.assetResults(
          currentFiat,
          (Assets asset, _, __) =>
              asset.assetId.equals(assetId),
          (_, __, ___) => Limit(1, null));
}
