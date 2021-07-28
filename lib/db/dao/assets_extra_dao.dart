import 'package:moor/moor.dart';

import '../mixin_database.dart';

part 'assets_extra_dao.g.dart';

@UseDao(tables: [AssetsExtra])
class AssetsExtraDao extends DatabaseAccessor<MixinDatabase>
    with _$AssetsExtraDaoMixin {
  AssetsExtraDao(MixinDatabase db) : super(db);

  Future<int> updateHidden(String assetId, bool hidden) =>
      into(db.assetsExtra).insertOnConflictUpdate(
          AssetsExtraData(assetId: assetId, hidden: hidden));
}
