import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

import '../mixin_database.dart';
import '../util/util.dart';

part 'collectible_dao.g.dart';

@UseDao(tables: [
  CollectibleToken,
  CollectibleTokenMeta,
])
class CollectibleDao extends DatabaseAccessor<MixinDatabase>
    with _$CollectibleDaoMixin {
  CollectibleDao(MixinDatabase attachedDatabase) : super(attachedDatabase);

  Selectable<CollectibleItem> getAllCollectibles() => db.collectiblesResult(
        (token, meta) => ignoreWhere,
        (token, meta) => OrderBy([OrderingTerm.desc(token.createdAt)]),
        (token, meta) => maxLimit,
      );

  Future<void> insertCollectible(sdk.CollectibleToken token) => batch((batch) {
        batch
          ..insertAllOnConflictUpdate(db.collectibleToken, [
            CollectibleTokenCompanion.insert(
              type: token.type,
              tokenId: token.tokenId,
              group: token.group,
              token: token.token,
              mixinId: token.mixinId,
              nfo: token.nfo,
              createdAt: DateTime.parse(token.createdAt),
              metaHash: token.meta.hash,
            )
          ])
          ..insertAllOnConflictUpdate(db.collectibleTokenMeta, [
            CollectibleTokenMetaCompanion.insert(
              group: token.meta.group,
              name: token.meta.name,
              description: token.meta.description,
              iconUrl: token.meta.iconUrl,
              mediaUrl: token.meta.mediaUrl,
              mime: token.meta.mime,
              hash: token.meta.hash,
              tokenId: token.tokenId,
            )
          ]);
      });

  Future<List<String>> filterExistsTokens(List<String> tokens) async {
    final exists = await (db.select(db.collectibleToken)
          ..where((tbl) => tbl.tokenId.isIn(tokens)))
        .map((token) => token.tokenId)
        .get();
    final result = tokens.toList()..remove(exists.toSet().contains);
    return result;
  }

  Selectable<CollectibleItem> collectibleItemByGroup(String group) =>
      db.collectiblesResult(
        (token, meta) => meta.group.equals(group),
        (token, meta) => OrderBy([OrderingTerm.desc(token.createdAt)]),
        (token, meta) => maxLimit,
      );

  Selectable<CollectibleItem> collectibleItemByTokenId(String tokenId) =>
      db.collectiblesResult(
        (token, meta) => token.tokenId.equals(tokenId),
        (token, meta) => OrderBy([OrderingTerm.desc(token.createdAt)]),
        (token, meta) => Limit(1, 0),
      );
}
