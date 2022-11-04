import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../mixin_database.dart';
import '../util/util.dart';

part 'collectible_dao.g.dart';

@DriftAccessor(tables: [
  CollectibleToken,
  CollectibleTokenMeta,
])
class CollectibleDao extends DatabaseAccessor<MixinDatabase>
    with _$CollectibleDaoMixin {
  CollectibleDao(MixinDatabase attachedDatabase) : super(attachedDatabase);

  Selectable<CollectibleItem> getAllCollectibles() => db.collectiblesResult(
        (token, meta, collection) => ignoreWhere,
        (token, meta, collection) =>
            OrderBy([OrderingTerm.desc(token.createdAt)]),
        (token, meta, collection) => maxLimit,
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
              collectionId: token.collectionId,
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
    final set = exists.toSet();
    return tokens.where((token) => !set.contains(token)).toList();
  }

  Future<List<String>> filterExistsCollections(
      List<String> collectionIds) async {
    final exists = await (db.select(db.collections)
          ..where((tbl) => tbl.collectionId.isIn(collectionIds)))
        .map((tbl) => tbl.collectionId)
        .get();
    final set = exists.toSet();
    return collectionIds.where((id) => !set.contains(id)).toList();
  }

  Selectable<CollectibleItem> collectibleItemByCollectionId(
          String collectionId) =>
      db.collectiblesResult(
        (token, meta, collection) =>
            collection.collectionId.equals(collectionId),
        (token, meta, collection) =>
            OrderBy([OrderingTerm.desc(token.createdAt)]),
        (token, meta, collection) => maxLimit,
      );

  Selectable<CollectibleItem> collectibleItemByTokenId(String tokenId) =>
      db.collectiblesResult(
        (token, meta, collection) => token.tokenId.equals(tokenId),
        (token, meta, collection) =>
            OrderBy([OrderingTerm.desc(token.createdAt)]),
        (token, meta, collection) => Limit(1, 0),
      );

  void removeNotExist(List<String> tokenIds) {
    batch((batch) {
      batch
        ..deleteWhere<CollectibleToken, CollectibleTokenData>(
            db.collectibleToken, (token) => token.tokenId.isNotIn(tokenIds))
        ..deleteWhere<CollectibleTokenMeta, CollectibleTokenMetaData>(
            db.collectibleTokenMeta, (tbl) => tbl.tokenId.isNotIn(tokenIds))
        ..deleteWhere<CollectibleOutput, CollectibleOutputData>(
            db.collectibleOutput, (tbl) => tbl.tokenId.isNotIn(tokenIds));
    });
  }

  Future<void> removeByTokenId(String tokenId) => batch((batch) {
        batch
          ..deleteWhere<CollectibleToken, CollectibleTokenData>(
              db.collectibleToken, (token) => token.tokenId.equals(tokenId))
          ..deleteWhere<CollectibleTokenMeta, CollectibleTokenMetaData>(
              db.collectibleTokenMeta, (tbl) => tbl.tokenId.equals(tokenId))
          ..deleteWhere<CollectibleOutput, CollectibleOutputData>(
              db.collectibleOutput, (tbl) => tbl.tokenId.equals(tokenId));
      });

  Future<int> insertCollection(sdk.CollectibleCollection collection) =>
      db.into(db.collections).insertOnConflictUpdate(
            CollectionsCompanion.insert(
              collectionId: collection.collectionId,
              name: collection.name,
              description: collection.description,
              iconUrl: collection.iconUrl,
              createdAt: collection.createdAt,
              type: collection.type,
            ),
          );

  Selectable<Collection> collection(String collectionId) =>
      db.select(db.collections)
        ..where((tbl) => tbl.collectionId.equals(collectionId));

  Future<void> updateOutputs(List<sdk.CollectibleOutput> outputs) =>
      batch((batch) {
        batch
          // clear outputs table
          ..deleteWhere(db.collectibleOutput, (tbl) => const Constant(true))
          ..insertAllOnConflictUpdate(
            db.collectibleOutput,
            outputs.map(
              (output) => CollectibleOutputCompanion.insert(
                userId: output.userId,
                outputId: output.outputId,
                tokenId: output.tokenId,
                transactionHash: output.transactionHash,
                outputIndex: output.outputIndex,
                amount: output.amount,
                sendersThreshold: output.sendersThreshold,
                senders: jsonEncode(output.senders),
                receiversThreshold: output.receiversThreshold,
                receivers: jsonEncode(output.receivers),
                state: output.state,
                createdAt: DateTime.parse(output.createdAt),
                updatedAt: DateTime.parse(output.updatedAt),
                signedBy: output.signedBy,
                signedTx: output.signedTx,
              ),
            ),
          );
      });

  Future<List<CollectibleOutputData>> getOutputsByTokenId(String tokenId) =>
      (db.select(db.collectibleOutput)
            ..where((tbl) => tbl.tokenId.equals(tokenId))
            ..orderBy([
              (tbl) => OrderingTerm.desc(tbl.createdAt),
            ]))
          .get();
}
