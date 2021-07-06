import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

import '../mixin_database.dart';

part 'asset_dao.g.dart';

@UseDao(tables: [Assets])
class AssetDao extends DatabaseAccessor<MixinDatabase> with _$AssetDaoMixin {
  AssetDao(MixinDatabase db) : super(db);

  Future<int> insert(Asset asset) =>
      into(db.assets).insertOnConflictUpdate(asset);

  Future deleteAsset(Asset asset) => delete(db.assets).delete(asset);

  Future<Asset?> findAssetById(String assetId) =>
      (select(db.assets)..where((t) => t.assetId.equals(assetId)))
          .getSingleOrNull();

  Future<void> insertAllOnConflictUpdate(List<sdk.Asset> assets) async {
    await db.update(db.assets).write(const AssetsCompanion(
      balance: Value('0.0'),
    ));
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.assets,
        assets
            .map((asset) => AssetsCompanion.insert(
          assetId: asset.assetId,
          symbol: asset.symbol,
          name: asset.name,
          iconUrl: asset.iconUrl,
          balance: asset.balance,
          destination: Value(asset.destination),
          tag: Value(asset.tag),
          assetKey: Value(asset.assetKey),
          priceBtc: asset.priceBtc,
          priceUsd: asset.priceUsd,
          chainId: asset.chainId,
          changeUsd: asset.changeUsd,
          changeBtc: asset.changeBtc,
          confirmations: asset.confirmations,
        ))
            .toList(),
      );
    });
  }

   Selectable<AssetResult> assets() => db.assetResults();
}
