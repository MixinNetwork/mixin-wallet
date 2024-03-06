import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' show Chain;

import '../mixin_database.dart' hide Chain;

part 'chain_dao.g.dart';

extension ChainConverter on Chain {
  ChainsCompanion get asChainsCompanion => ChainsCompanion.insert(
        chainId: chainId,
        name: name,
        symbol: symbol,
        iconUrl: iconUrl,
        threshold: threshold,
      );
}

@DriftAccessor(
  include: {'../moor/dao/chain.drift'},
)
class ChainDao extends DatabaseAccessor<MixinDatabase> with _$ChainDaoMixin {
  ChainDao(super.db);

  Future<int> insertSdkChain(Chain chain) =>
      into(db.chains).insertOnConflictUpdate(chain.asChainsCompanion);

  Future<void> insertAllOnConflictUpdate(List<Chain> chains) => batch((batch) {
        batch.insertAllOnConflictUpdate(
          db.chains,
          chains.map((chain) => chain.asChainsCompanion).toList(),
        );
      });
}
