import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../mixin_database.dart';

part 'fiat_dao.g.dart';

@DriftAccessor(tables: [Fiat])
class FiatDao extends DatabaseAccessor<MixinDatabase> with _$FiatDaoMixin {
  FiatDao(MixinDatabase db) : super(db);

  Future<int> insert(Fiat fiat) => into(db.fiats).insertOnConflictUpdate(fiat);

  Future<void> insertAll(List<Fiat> fiats) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.fiats, fiats);
      });

  Future<int> deleteFiat(Fiat fiat) => delete(db.fiats).delete(fiat);

  Future<void> insertAllOnConflictUpdate(List<sdk.Fiat> fiats) async {
    await db.delete(db.fiats).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.fiats,
        fiats
            .map((fiat) => FiatsCompanion.insert(
                  code: fiat.code,
                  rate: fiat.rate,
                ))
            .toList(),
      );
    });
  }

  SimpleSelectStatement<Fiats, Fiat> fiats() => select(db.fiats);
}
