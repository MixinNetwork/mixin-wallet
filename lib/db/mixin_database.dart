import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart'
    show UserRelationship;

import 'converter/millis_date_converter.dart';
import 'converter/user_relationship_converter.dart';
import 'dao/address_dao.dart';
import 'dao/asset_dao.dart';
import 'dao/assets_extra_dao.dart';
import 'dao/collectible_dao.dart';
import 'dao/fiat_dao.dart';
import 'dao/snapshot_dao.dart';
import 'dao/user_dao.dart';
import 'database_event_bus.dart';

part 'mixin_database.g.dart';

@DriftDatabase(
  include: {
    'moor/mixin.drift',
    'moor/dao/asset.drift',
    'moor/dao/snapshot.drift',
    'moor/dao/user.drift',
    'moor/dao/collectible.drift'
  },
  daos: [
    AddressDao,
    AssetDao,
    SnapshotDao,
    UserDao,
    FiatDao,
    AssetsExtraDao,
    CollectibleDao,
  ],
  queries: {},
)
class MixinDatabase extends _$MixinDatabase {
  MixinDatabase(QueryExecutor e) : super(e);

  MixinDatabase.connect(DatabaseConnection c) : super.connect(c);

  @override
  int get schemaVersion => 5;

  final eventBus = DataBaseEventBus();

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (_) async {
          if (executor.dialect == SqlDialect.sqlite) {
            await customStatement('PRAGMA journal_mode=WAL');
            await customStatement('PRAGMA foreign_keys=ON');
            await customStatement('PRAGMA synchronous=NORMAL');
          }
        },
        onUpgrade: (m, from, to) async {
          // delete all tables and restart
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
            await m.createTable(table);
          }
        },
      );
}
